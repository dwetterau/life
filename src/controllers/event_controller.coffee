{Event} = require '../models'

exports.get_event_add = (req, res) ->
  res.render 'event/add', {
    user: req.user
    title: 'Add Event'
  }

exports.post_event_add = (req, res) ->
  req.assert('date', 'Must provide a valid date.').notEmpty()
  errors = req.validationErrors()
  fail = (errors) ->
    res.send {status: 'error', errors: errors}
  if errors
    return fail errors

  new_event = Event.build {
    date: req.body.date
    detail: req.body.detail
    UserId: req.user.id
  }
  new_event.save().success () ->
    res.send {status: 'ok', new_event: new_event.to_json()}
  .failure fail
