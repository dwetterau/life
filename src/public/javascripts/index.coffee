# Import React
React = require 'react'
{EditEvent} = require '../../components/edit_event'
{LifeApp} = require '../../components/life_app'

# Client-side stuff here
# Initialize the material effects
$.material.init()

if $('div#edit_event_container').length

  # Initialize the time/date picker
  event = {detail: "", date: moment()}
  console.log "setting the event to be:", event
  React.render(React.createElement(EditEvent, {event}), $("div#edit_event_container").get(0))

if $('div#life_app').length
  # Copy in the initial state and render everything
  initial_state = JSON.parse($('script#initial_state').html())
  React.render(React.createElement(LifeApp, {events: initial_state}),
    $("#life_app").get(0))
