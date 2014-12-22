express = require 'express'
router = express.Router()
passport_config  = require('../lib/auth')

event_controller = require '../controllers/event_controller'
index_controller = require '../controllers/index_controller'
user_controller = require '../controllers/user_controller'

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

module.exports = router
