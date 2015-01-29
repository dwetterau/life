# Import React
React = require 'react'
{LifeApp} = require '../../components/life_app'
{IntegrationMenu} = require '../../components/integration_menu'

# Client-side stuff here
# Initialize the material effects
$.material.init()

life_app_div = document.getElementById 'life_app'
if life_app_div
  # Copy in the initial state and render everything
  initial_state = JSON.parse(document.getElementById('initial_state').innerHTML)
  React.render(React.createElement(LifeApp, initial_state),
    life_app_div)

integration_menu_div = document.getElementById 'integration_menu'
if integration_menu_div
  # Copy in the initial state and render everything
  initial_state = JSON.parse(document.getElementById('initial_state').innerHTML)
  React.render(React.createElement(IntegrationMenu, initial_state), integration_menu_div)

# Set up the navigation button
toggleMenu = () ->
  $("#menu-toggle-button").unbind 'click'
  setTimeout () ->
    $('.mega-container').addClass('side-menu-open')
    $('html').bind 'click', () ->
      $('.mega-container').removeClass('side-menu-open')
      $('html').unbind('click')
      $("#menu-toggle-button").bind 'click', toggleMenu
  , 25
$("#menu-toggle-button").bind 'click', toggleMenu

# Render user forms
if $('#create_account').length
  {CreateUser} = require '../../components/user/create_user'
  React.render React.createElement(CreateUser, null), $('#create_account').get(0)

if $('#change_password').length
  {ChangePassword} = require '../../components/user/change_password'
  React.render React.createElement(ChangePassword, null), $('#change_password').get(0)

if $('#login').length
  {Login} = require '../../components/user/login'
  props = JSON.parse($('#props').html())
  React.render React.createElement(Login, props), $('#login').get(0)
