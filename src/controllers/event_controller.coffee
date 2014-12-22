models = require '../models'

exports.get_event_add = (req, res) ->
  res.render 'event/add', {
    user: req.user
    title: 'Add Event'
  }