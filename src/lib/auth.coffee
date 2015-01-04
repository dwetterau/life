passport = require 'passport'
LocalStrategy = require 'passport-local'

# Dropbox integration configs
DropboxOAuth2Strategy = require('passport-dropbox-oauth2').Strategy
{config} = require('./common')

models = require '../models'

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  models.User.find(id).success (user) ->
    done null, user
  .failure (err) ->
    done err

passport.use new LocalStrategy {usernameField: 'username'}, (username, password, done) ->
  models.User.find({where: {username}}).success (user) ->
    if not user
      return done null, false, {message: 'Invalid username or password.'}
    user.compare_password password, (err, is_match) ->
      if is_match
        return done null, user
      else
        return done null, false, {message: 'Invalid username or password.'}

passport.use new DropboxOAuth2Strategy {
  clientID: config.get('api_key')
  clientSecret: config.get('api_secret')
  callbackURL: config.get('callback_url')
}, (accessToken, refreshToken, profile, done) ->
  # TODO: Look up the user based on the profile.id (Dropbox id) in our integrations table,
  # Update the access tokens with it
  err = null
  user = {}
  done err, user

exports.isAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/user/login?r=' + encodeURIComponent(req.url)
