{Event} = require '../models'

exports.get_event_add = (req, res) ->
  res.render 'event/add', {
    user: req.user
    title: 'Add Event'
  }

exports.post_event_add = (req, res) ->
  req.assert('date', 'Must provide a valid date.').notEmpty()
  validation_errors = req.validationErrors()
  fail = (errors) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  new_event = Event.build {
    date: req.body.date
    detail: req.body.detail
    UserId: req.user.id
  }
  new_event.save().success () ->
    res.send {status: 'ok', new_event: new_event.to_json()}
  .failure fail


exports.post_event_update = (req, res)  ->
  req.assert('date', 'Must provide a valid date.').notEmpty()
  req.assert('id', 'Must provide an event id.').isInt()
  validation_errors = req.validationErrors()
  fail = (errors) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  updated_event = null
  Event.find(req.body.id).success (event) ->
    if event.UserId != req.user.id
      return fail(msg: "You are not authorized to edit that event.")

    event.date = req.body.date
    event.detail = req.body.detail
    updated_event = event
    return event.save()
  .success () ->
    res.send {status: 'ok', new_event: updated_event.to_json()}
  .failure fail
