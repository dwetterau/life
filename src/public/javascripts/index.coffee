# Import React
React = require 'react'
{EditEvent} = require '../../components/edit_event'
{LifeApp} = require '../../components/life_app'

# Client-side stuff here
# Initialize the material effects
$.material.init()

life_app_div = document.getElementById 'life_app'
if life_app_div
  # Copy in the initial state and render everything
  initial_state = JSON.parse(document.getElementById('initial_state').innerHTML)
  React.render(React.createElement(LifeApp, {events: initial_state}),
    life_app_div)
