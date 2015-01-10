{Event, Label} = require '../models'

exports.get_event_add = (req, res) ->
  res.render 'event/add', {
    user: req.user
    title: 'Add Event'
  }

make_unique = (array) ->
  m = {}
  result = []
  for e in array
    if e of m
      continue
    m[e] = true
    result.push e
  result

get_new_labels = (array_string, user_id, event_id) ->
  unique = make_unique array_string.split(" ")
  get_label = (label_string) ->
    name: label_string
    UserId: user_id
    EventId: event_id

  (get_label(l.toLowerCase()) for l in unique)

to_json_with_labels = (event, labels) ->
  event = event.to_json()
  event.labels = (l.to_json() for l in labels)
  return event

exports.post_event_add = (req, res) ->
  req.assert('date', 'Must provide a valid date.').notEmpty()
  validation_errors = req.validationErrors()
  fail = (errors...) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  new_event = Event.build {
    date: req.body.date
    detail: req.body.detail
    UserId: req.user.id
  }
  labels = req.body.labels
  new_event.save().success () ->
    # Create label objects for all of the labels
    return Label.bulkCreate get_new_labels(labels, req.user.id, new_event.id)
  .success (new_labels) ->
    res.send {status: 'ok', new_event: to_json_with_labels(new_event, new_labels)}
  .failure fail


exports.post_event_update = (req, res)  ->
  req.assert('date', 'Must provide a valid date.').notEmpty()
  req.assert('id', 'Must provide an event id.').isInt()
  validation_errors = req.validationErrors()
  fail = (errors...) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  updated_event = null
  labels=  req.body.labels
  Event.find(req.body.id).success (event) ->
    if event.UserId != req.user.id
      return fail(msg: "You are not authorized to edit that event.")

    event.date = req.body.date
    event.detail = req.body.detail
    updated_event = event
    return event.save()
  .success () ->
    # Kill all the old labels
    return Label.destroy {where: {EventId: updated_event.id}}
  .success () ->
    return Label.bulkCreate get_new_labels(labels, req.user.id, updated_event.id)
  .success (new_labels) ->
    res.send {status: 'ok', new_event: to_json_with_labels(updated_event, new_labels)}
  .failure fail

event_modification_endpoint = (new_state, req, res) ->
  req.assert('id', 'Must provide an event id.').isInt()
  validation_errors = req.validationErrors()
  fail = (errors...) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  Event.find(req.body.id).success (event) ->
    if event.UserId != req.user.id
      return fail(msg: "You are not authorized to edit that event.")
    event.state = new_state
    return event.save()
  .success () ->
    res.send {status: 'ok'}
  .failure fail

exports.post_event_archive = (req, res) ->
  event_modification_endpoint 'archived', req, res

exports.post_event_restore = (req, res) ->
  event_modification_endpoint 'active', req, res

exports.post_event_delete = (req, res) ->
  event_modification_endpoint 'deleted', req, res
