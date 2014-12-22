# Import React
React = require 'react'
{Selector} = require '../../components/time_selector'
{LifeApp} = require '../../components/life_app'

# Client-side stuff here
# Initialize the material effects
$.material.init()

if $('form#add_event').length

  # Initialize the time/date picker
  React.render(React.createElement(Selector), $("#selector_container").get(0))

  # Initialize the editor
  editor = new Quill '#editor', {
    modules:
      'toolbar': {container: '#toolbar'}
      'link-tooltip': true
      'image-tooltip': true
    theme: 'snow'
  }
  editor.on 'text-change', () ->
    $('#detail').val editor.getHTML()
  $('#toolbar').show()
  $('#editor').click () ->
    $('.ql-editor').get(0).focus()

if $('div#life_app').length
  # Copy in the initial state and render everything
  initial_state = JSON.parse($('script#initial_state').html())
  React.render(React.createElement(LifeApp, {events: initial_state}),
    $("#life_app").get(0))
