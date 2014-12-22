React = require 'react'
{LifeApp} = require '../components/life_app'
{Event} = require '../models'

exports.get_index = (req, res) ->
  render_dict = {
    user: req.user
    title: 'Home'
  }
  if req.user
    req.user.getEvents().success (events) ->
      events = (e.to_json() for e in events)
      markup = React.renderToString(LifeApp {events})
      render_dict.markup = markup
      render_dict.state = JSON.stringify(events)
      res.render 'index', render_dict
  else
    res.render 'index', render_dict
