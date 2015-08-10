passport = require 'passport'
{Integration} = require '../models'

exports.get_connect_gcal = (req, res, next) ->
  Integration.findOne({where: {UserId: req.user.id, type: 'gcal'}}).then (result) ->
    if not result
      # We haven't done gcal integration, start it through passport
      passport.authenticate('google')(req, res, next)
    else
      # We already have an auth token, this shouldn't happen
      # TODO: verify that the token hasn't been revoked, this might
      # not happen on this call though
      res.redirect '/integrations'
  .catch (err) ->
    console.log "Error getting stuff from Google"
    console.log err
    req.flash "errors", {msg: "Failed to check your Google calendar integration."}
    res.redirect '/integrations'

exports.get_connect_gcal_callback = (req, res, next) ->
  key = null
  uid = null
  passport.authenticate('google', {failureRedirect: '/integrations'}, (err, googleUser) ->
    if not key and not uid
      key = googleUser.accessToken
      uid = googleUser.profile.id
    new_integration = {
      type: 'gcal'
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
