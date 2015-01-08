async = require 'async'
Dropbox = require 'dropbox'
fs = require 'fs'
moment = require 'moment'
uuid = require 'uuid'
{config, constants} = require '../../lib/common'
{Integration} = require '../../models'

# The initial approach for this program will be as follows:
# 1. get the latest cursor for all dropbox accounts (don't include_media_info,
#     not compatible with longpoll)
# 2. make the longpoll delta call for each of the accounts
# 3. when the longpoll returns that there were changes, call /delta for that
#     user without include_media_info
# 4. Go back to 3 if needed (calling delta again if there were more changes)
# 5. For all changed image files, download them with the /thumbnail endpoint
#     to a folder that nginx can serve quickly
# 6. Store metadata about each downloaded photo to get a unique photo id and
#     connect it to user for easier account destruction
# 7. Create a new event for that user at the earliest time of a photo in the
#     delta and make the detail contain links to the new images
# 8. Get the latest cursor again (no include_media_info) and wait on the
#     longpoll delta call, return to 2
listenForPhotos = (client, integration) ->
  pendingImages = {}

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
      photoExtension = (path) ->
        supported_extensions = ['.jpg', '.jpeg', '.png', '.tiff', '.tif', '.gif', '.bmp']
        for e in supported_extensions
          if path.length > e.length and path.indexOf e == path.length - e.length
            return true
        return false

      path = change.path
      if not change.wasRemoved and s and s.isFile and photoExtension path
        date = moment(s.modifiedAt)
        id = uuid.v4()
        pendingImages[path] = {path, id, date, mimeType: s.mimeType, UserId: integration.UserId}

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
      new_path = config.get('dropbox_photo_dir') + '/' + size + '/' + data.id
      fs.writeFile new_path, buffer, (error) ->
        if error
          console.log "Error writing thumbnail to disk"
          return callback(error)

        callback(null)


  processPhoto = (data, callback) ->
    sizes = ['m', 'xl']
    async.each sizes, ((size, c) -> downloadAndSaveThumbnail data, size, c), callback


  processNewPhotos = (cursor) ->
    # Download the photos, put them in the Db, make the event
    console.log "Step 5"
    data = (d for path, d of pendingImages)
    async.each data, ((d, c) -> processPhoto d, c), (error) ->
      if error
        return console.log "Some thumbnail failed to download or save"

      console.log "Finished saving images to disk", pendingImages
      # Step 6 and 7 here

      # Free up the memory
      pendingImages = {}

      # Step 8
      console.log "Step 8"
      longpollDelta cursor

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

Integration.findAll({where: {type: 'dropbox'}}).success (integrations) ->
  for integration in integrations
    client = new Dropbox.Client {token: integration.key}
    listenForPhotos(client, integration)
