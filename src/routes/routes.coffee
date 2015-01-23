express = require 'express'
passport = require 'passport'
router = express.Router()
passport_config  = require('../lib/auth')

event_controller = require '../controllers/event_controller'
index_controller = require '../controllers/index_controller'
user_controller = require '../controllers/user_controller'
integration_controller = require '../controllers/integration_controller'

dropbox_controller = require '../controllers/dropbox_controller'
google_calendar_controller = require '../controllers/google_calendar_controller'

# GET home page
router.get '/', index_controller.get_index
router.get '/archive', passport_config.isAuthenticated, index_controller.get_archive

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
router.post '/event/restore', passport_config.isAuthenticated, event_controller.post_event_restore
router.post '/event/delete', passport_config.isAuthenticated, event_controller.post_event_delete

# Integration routes
router.get '/integrations', passport_config.isAuthenticated, integration_controller.get_index

# Dropbox integration auth routes
router.get '/integrations/dropbox', passport_config.isAuthenticated,
  dropbox_controller.get_connect_dropbox
router.get '/integrations/dropbox/callback', passport_config.isAuthenticated,
  dropbox_controller.get_connect_dropbox_callback

# Google calendar integration auth routes
router.get '/integrations/gcal', passport_config.isAuthenticated,
  google_calendar_controller.get_connect_gcal
router.get '/integrations/gcal/callback', passport_config.isAuthenticated,
  google_calendar_controller.get_connect_gcal_callback

module.exports = router
