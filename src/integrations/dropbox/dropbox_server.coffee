Dropbox = require 'dropbox'
{config, constants} = require '../../lib/common'
{Integration} = require '../../models'

# The initial approach for this program will be as follows:
# 1. get the latest cursor for all dropbox accounts (don't include_media_info,
#     not compatible with longpoll)
# 1.5 get the latest cursor with media info to make the /delta call with
# 2. make the longpoll delta call for each of the accounts
# 3. when the longpoll returns that there were changes, call /delta for that
#     user with include_media_info
# 4. For all changed image files, download them with the /thumbnail endpoint
#     to a folder that nginx can serve quickly
# 5. Go back to 3 if needed (calling delta again if there were more changes)
# 6. Store metadata about each downloaded photo to get a unique photo id and
#     connect it to user for easier account destruction
# 7. Create a new event for that user at the earliest time of a photo in the
#     delta and make the detail contain links to the new images
# 8. Get the latest cursor again (no include_media_info) and wait on the
#     longpoll delta call, return to 2
listenForPhotos = (client, integration) ->

  # Just used to get the cursors to longpoll with.
  # It should be the callback to the initial latestCursor call without parameters
  latestCursorCallback = (error, pulledChanges) ->
    if error
      # TODO: delete integration if auth is bad
      console.log error
      return
    # Step 2
    console.log "Step 1.5"
    client.latestCursor {includeMediaInfo: true}, (error, mediaPulledChanges) ->
      if error
        console.log error
        return
      console.log "Step 2"
      longpollDelta pulledChanges.cursorTag, mediaPulledChanges.cursorTag

  # Callback for after we retrieve a new cursor from a call to /delta or /delta/latest_cursor
  pullChangesCallback = (error, pulledChanges) ->
    if error
      # TODO: if the error is that the user is unauthorized, we should delete the integration
      console.log error
      return

    # Step 4 - 7 will need to happen here.
    console.log "There were changes! printing them now."
    console.log "These changes were for user with id=" + integration.UserId
    console.log pulledChanges
    for change in pulledChanges.changes
      console.log change

    # Step 8
    # TODO: Eliminate one of the calls to latest cursor by using the last cursor here
    console.log "Step 8"
    client.latestCursor latestCursorCallback

  longpollDelta = (cursor, media_cursor) ->
    pollingCallback = (error, pollResult) ->
      console.log "got pollResult:"
      console.log pollResult
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
          client.pullChanges media_cursor, {includeMediaInfo: true}, pullChangesCallback
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
