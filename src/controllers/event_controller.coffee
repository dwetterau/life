React = require 'react'
{Selector} = require '../components/time_selector'

models = require '../models'

exports.get_event_add = (req, res) ->
  time_selector = React.renderComponentToString(Selector())

  res.render 'event/add', {
    time_selector
    user: req.user
    title: 'Add Event'
  }