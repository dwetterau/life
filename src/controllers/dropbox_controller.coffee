passport = require 'passport'
{Integration} = require '../models'

exports.get_connect_dropbox = (req, res, next) ->
  Integration.findOne({where: {UserId: req.user.id, type: 'dropbox'}}).then (result) ->
    if not result
      # We haven't done dropbox integration, start it through passport
      passport.authenticate('dropbox-oauth2')(req, res, next)
    else
      # We already have an auth token, this shouldn't happen
      # TODO: verify that the token hasn't been revoked, this might
      # not happen on this call though
      res.redirect '/integrations'
  .catch (err) ->
    console.log "Error getting stuff from Dropbox"
    console.log err
    req.flash "errors", {msg: "Failed to check your Dropbox integration."}
    res.redirect '/integrations'

exports.get_connect_dropbox_callback = (req, res, next) ->
  key = null
  uid = null
  passport.authenticate('dropbox-oauth2', {failureRedirect: '/integrations'}, (err, dropboxUser) ->
    if not key and not uid
      key = dropboxUser.accessToken
      uid = dropboxUser.profile.id
    new_integration = {
      type: 'dropbox'
      UserId: req.user.id
      key
      uid
    }
    Integration.build(new_integration).save().then () ->
      res.redirect '/integrations'
    .catch () ->
      req.flash "errors", {msg: "Failed to authenticate."}
      res.redirect '/integrations'
  )(req, res, next)
