Dropbox = require 'dropbox'
{config, constants} = require '../../lib/common'

client = new Dropbox.Client {
  token: config.get("auth_token")
}
console.log client.isAuthenticated()
client.getAccountInfo (err, account_info) ->
  console.log account_info.json()