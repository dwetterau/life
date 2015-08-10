passport = require 'passport'
LocalStrategy = require 'passport-local'

# Dropbox integration configs
DropboxOAuth2Strategy = require('passport-dropbox-oauth2').Strategy

# Google integration configs
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

{config} = require('./common')

models = require '../models'

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  models.User.findById(id).then (user) ->
    # Capitalize the username
    user.username = user.username.charAt(0).toUpperCase() + user.username.slice(1)
    done null, user
  .catch (err) ->
    done err

passport.use new LocalStrategy {usernameField: 'username'}, (username, password, done) ->
  models.User.findOne({where: {username}}).then (user) ->
    if not user
      return done null, false, {message: 'Invalid username or password.'}
    user.compare_password password, (err, is_match) ->
      if is_match
        return done null, user
      else
        return done null, false, {message: 'Invalid username or password.'}

passport.use new DropboxOAuth2Strategy {
  clientID: config.get('dropbox_api_key')
  clientSecret: config.get('dropbox_api_secret')
  callbackURL: config.get('dropbox_callback_url')
}, (accessToken, refreshToken, profile, done) ->
  done null, {profile, accessToken}

passport.use new GoogleStrategy {
  clientID: config.get('gcal_consumer_key')
  clientSecret: config.get('gcal_consumer_secret')
  callbackURL: config.get('gcal_callback_url')
  scope: ['openid', 'email', 'https://www.googleapis.com/auth/calendar']
}, (accessToken, refreshToken, profile, done) ->
  done null, {profile, accessToken}

exports.isAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  res.redirect '/user/login?r=' + encodeURIComponent(req.url)
