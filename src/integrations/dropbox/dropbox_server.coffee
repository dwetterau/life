Dropbox = require 'dropbox'
{config, constants} = require '../../lib/common'
{Integration} = require '../../models'

client = new Dropbox.Client {
  token: config.get("auth_token")
}

# The initial approach for this program will be as follows:
# 1. get the latest cursor for all dropbox accounts (don't include_media_info, not compatible with delta)
# 2. make the longpoll delta call for each of the accounts
# 3. when the longpoll returns that there were changes, call /delta for that user with include_media_info
# 4. For all changed image files, download them with the /thumbnail endpoint to a folder
#    that nginx can serve quickly
# 5. Go back to 3 if needed
# 5. Store metadata about each downloaded photo to get a unique photo id and connect it to user for
#    easier account destruction
# 6. Create a new event for that user at the earliest time of a photo in the delta and make the
#    detail contain links to the new images
# 7. Get the latest cursor again (no include_media_info) and wait on the longpoll delta call
clients = {}
Integration.findAll({where: {type: 'dropbox'}}).success (integrations) ->
  for integration in integrations
    # TODO: make sure the token is still valid
    clients[integration.UserId] = new Dropbox.Client {token: integration.key}
