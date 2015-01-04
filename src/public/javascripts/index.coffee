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
  React.render(React.createElement(LifeApp, {events: initial_state}),
    life_app_div)

integration_menu_div = document.getElementById 'integration_menu'
if integration_menu_div
  # Copy in the initial state and render everything
  initial_state = JSON.parse(document.getElementById('initial_state').innerHTML)
  React.render(React.createElement(IntegrationMenu, initial_state), integration_menu_div)
