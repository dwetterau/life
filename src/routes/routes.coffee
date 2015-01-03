express = require 'express'
passport = require 'passport'
router = express.Router()
passport_config  = require('../lib/auth')

event_controller = require '../controllers/event_controller'
index_controller = require '../controllers/index_controller'
user_controller = require '../controllers/user_controller'

dropbox_controller = require '../controllers/dropbox_controller'

# GET home page
router.get '/', index_controller.get_index

# User routes
router.get '/user/create', user_controller.get_user_create
router.post '/user/create', user_controller.post_user_create
router.get '/user/login', user_controller.get_user_login
router.post '/user/login', user_controller.post_user_login
router.get '/user/logout', user_controller.get_user_logout
router.get '/user/password', passport_config.isAuthenticated, user_controller.get_change_password
router.post '/user/password', passport_config.isAuthenticated, user_controller.post_change_password

# Event routes
router.get '/event/add', passport_config.isAuthenticated, event_controller.get_event_add
router.post '/event/add', passport_config.isAuthenticated, event_controller.post_event_add
router.post '/event/update', passport_config.isAuthenticated, event_controller.post_event_update
router.post '/event/archive', passport_config.isAuthenticated, event_controller.post_event_archive

# Dropbox integration auth routes
router.get '/auth/dropbox/', passport.authenticate('dropbox-oauth2')
router.get '/auth/dropbox/callback', passport.authenticate(
  'dropbox-oauth2', {'failureRedirect': '/integrations/dropbox'})
, dropbox_controller.get_home_logged_in
router.get '/integrations/dropbox', dropbox_controller.get_home_logged_out

module.exports = router
