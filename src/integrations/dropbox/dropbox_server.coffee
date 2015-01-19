async = require 'async'
Dropbox = require 'dropbox'
fs = require 'fs'
jade = require 'jade'
moment = require 'moment'
path_lib = require 'path'
uuid = require 'uuid'
{config, constants} = require '../../lib/common'
{Event, Image, Integration} = require '../../models'

# The initial approach for this program will be as follows:
# 1. get the latest cursor for all dropbox accounts (don't include_media_info,
#     not compatible with longpoll)
# 2. make the longpoll delta call for each of the accounts
# 3. when the longpoll returns that there were changes, call /delta for that
#     user without include_media_info
# 4. Go back to 3 if needed (calling delta again if there were more changes)
# 5. For all changed image files, download them with the /thumbnail endpoint
#     to a folder that nginx can serve quickly
# 6. Create a new event for that user at the earliest time of a photo in the
#     delta and make the detail contain links to the new images
# 7. Store metadata about each downloaded photo to get a unique photo id and
#     connect it to user for easier account destruction
# 8. Get the latest cursor again (no include_media_info) and wait on the
#     longpoll delta call, return to 2
listenForPhotos = (client, integration) ->
  pendingImages = {}
  lastUpdatedEvent = {id: null}

  # Just used to get the cursors to longpoll with.
  # It should be the callback to the initial latestCursor call without parameters
  latestCursorCallback = (error, pulledChanges) ->
    if error
      # TODO: delete integration if auth is bad
      console.log error
      return
    # Step 2
    console.log "Step 2"
    longpollDelta pulledChanges.cursorTag

  # Callback for after we retrieve a new cursor from a call to /delta or /delta/latest_cursor
  pullChangesCallback = (error, pulledChanges) ->
    if error
      # TODO: if the error is that the user is unauthorized, we should delete the integration
      console.log error
      return

    # Step 4 - 7 will need to happen here.
    for change in pulledChanges.changes
      # Determine if the file is a new image
      s = change.stat
      photoExtension = (p) ->
        supported_extensions = ['.jpg', '.jpeg', '.png', '.tiff', '.tif', '.gif', '.bmp']
        for e in supported_extensions
          if p.length > e.length and p.indexOf e == p.length - e.length
            return true
        return false

      path = change.path
      if not change.wasRemoved and s and s.isFile and photoExtension path
        date = moment(s.modifiedAt)
        id = uuid.v4()
        pendingImages[path] =
          {path, uuid: id, date, mimeType: s.mimeType, UserId: integration.UserId}

    # Keep pulling if we have to
    if pulledChanges.shouldPullAgain
      console.log "Step 4"
      client.pullChanges pulledChanges, pullChangesCallback
    else
      processNewPhotos pulledChanges.cursorTag

  getNewPhotoMetadata = (cursor) ->
    pendingImages = {}
    client.pullChanges cursor, pullChangesCallback

  downloadAndSaveThumbnail = (data, size, callback) ->
    options = {buffer: true, size}
    client.readThumbnail data.path, options, (error, buffer, stat) ->
      if error
        console.log "There was an error downloading a thumbnail"
        return callback(error)
      new_path = path_lib.join(config.get('dropbox_photo_dir'), size + '/' + data.uuid)
      fs.writeFile new_path, buffer, (error) ->
        if error
          console.log "Error writing thumbnail to disk"
          return callback(error)

        callback(null)

  updatedLongAgo = () ->
    diff = lastUpdatedEvent.time.fromNow(true)
    if diff.indexOf 'seconds' == 0
      return false
    if diff.indexOf 'minute' >= 2
      # either happened within the last minute or hour
      time = diff.split(' ')[0]
      if time == 'a'
        return false
      return time > 15
    return true

  getEarliestPhotoDate = () ->
    min = null
    for p, data of pendingImages
      if not min?
        min = moment(data.date)
      else
        t = moment(data.date)
        if t.isBefore min
          min = t
    return min.toDate()

  getEventDetail = (existingImages, callback) ->
    # Merge the new photos into the existing ones. Overwriting ones with the same path
    allImages = {}
    for image in existingImages
      allImages[image.path] = image

    for p, data of pendingImages
      allImages[p] = data

    imageRows = []
    row = []
    for p, image of allImages
      if row.length < 4
        row.push image
      else
        imageRows.push row
        row = [image]
    if row.length
      imageRows.push row

    hostname = config.get('hostname')

    # Render the image rows
    template = path_lib.join(__dirname, '../../views/image/image_detail.jade')
    jade.renderFile template, {imageRows, hostname}, callback

  createOrUpdateEvent = (callback) ->
    # Step 6
    saveEvent = (event) ->
      event.encrypt()
      event.save().then () ->
        lastUpdatedEvent.id = event.id
        lastUpdatedEvent.time = moment()
        callback(null, event.id)
      .catch callback

    makeNewEvent = () ->
      # Create a new event
      eventDictionary = {
        date: getEarliestPhotoDate()
        UserId: integration.UserId
        state: 'active'
      }
      getEventDetail [], (error, detail) ->
        if error
          console.log "error rendering image detail"
          return callback error
        eventDictionary.detail = detail
        event = Event.build eventDictionary
        saveEvent(event)

    if not lastUpdatedEvent.id? or updatedLongAgo()
      makeNewEvent()
    else
      # Update an existing event
      Event.find({where: {id: lastUpdatedEvent.id}, include: [Image]}).then (event) ->
        if event.state != 'active'
          return makeNewEvent()
        if moment(event.updatedAt).isAfter(lastUpdatedEvent.time)
          return makeNewEvent()

        existingImages = (image.to_json() for image in event.Images)
        getEventDetail existingImages, (error, detail) ->
          if error
            console.log "error rendering image detail"
            return callback error
          event.detail = detail
          saveEvent(event)
      .catch callback

  savePhotoMetadata = (callback) ->
    new_images = []
    for path, data of pendingImages
      new_images.push {
        path
        date: data.date
        uuid: data.uuid
        mime: data.mimeType
        UserId: integration.UserId
        EventId: lastUpdatedEvent.id
      }
    Image.bulkCreate(new_images).then () ->
      callback()
    .catch callback

  processPhoto = (data, callback) ->
    sizes = ['m', 'xl']
    async.each sizes, ((size, c) -> downloadAndSaveThumbnail data, size, c), callback

  processNewPhotos = (cursor) ->
    pollAgain = () ->
      longpollDelta cursor

    # If there are no images, there are none to process
    if Object.keys(pendingImages).length == 0
      return pollAgain()

    # Download the photos, put them in the Db, make the event
    data = (d for path, d of pendingImages)
    async.series [
      # Step 5
      (callback) ->
        console.log "Step 5"
        async.each data, ((d, c) -> processPhoto d, c), callback

      # Step 6
      (callback) ->
        console.log "Step 6"
        createOrUpdateEvent callback

      # Step 7
      (callback) ->
        console.log "Step 7"
        savePhotoMetadata callback
    ], (error) ->
      if error
        console.log "error while processing photos"
        return console.log error
      console.log "Step 8"
      pendingImages = {}
      pollAgain()

  longpollDelta = (cursor) ->
    pollingCallback = (error, pollResult) ->
      if error
        # TODO: depending on the error, we might want to check again
        console.log error
        return

      # Call pollForChanges again after the timeout
      properDelay = (callback) ->
        delay = if pollResult.retryAfter? then pollResult.retryAfter * 1000 else 0
        setTimeout callback, delay

      # After the right delay, either pull down the new changes or poll again
      properDelay () ->
        if pollResult.hasChanges
          # Step 3
          console.log "Step 3"
          getNewPhotoMetadata cursor
        else
          client.pollForChanges cursor, pollingCallback

    # Make the initial call to start listening for changes
    client.pollForChanges cursor, pollingCallback

  # Step 1
  console.log "Step 1"
  client.latestCursor latestCursorCallback

Integration.findAll({where: {type: 'dropbox'}}).then (integrations) ->
  for integration in integrations
    client = new Dropbox.Client {token: integration.key}
    listenForPhotos(client, integration)
