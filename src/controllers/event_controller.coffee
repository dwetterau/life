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
  return result

exports.post_event_add = (req, res) ->
  req.assert('date', 'Must provide a valid date.').notEmpty()
  validation_errors = req.validationErrors()
  fail = (errors) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  labels = make_unique(req.body.labels.split(" "))
  new_event = Event.build {
    date: req.body.date
    detail: req.body.detail
    UserId: req.user.id
  }
  new_event.save().success () ->
    # Create label objects for all of the labels
    get_label = (label_string) ->
      name: label_string
      UserId: req.user.id
      EventId: event.id
    all_new_labels = (get_label(l) for l in labels)
    return Label.bulkCreate all_new_labels
  .success () ->
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

exports.post_event_archive = (req, res) ->
  req.assert('id', 'Must provide an event id.').isInt()
  validation_errors = req.validationErrors()
  fail = (errors) ->
    res.send {status: 'error', errors: errors}
  if validation_errors
    return fail validation_errors

  Event.find(req.body.id).success (event) ->
    if event.UserId != req.user.id
      return fail(msg: "You are not authorized to edit that event.")
    event.state = 'archived'
    return event.save()
  .success () ->
    res.send {status: 'ok'}
  .failure fail

