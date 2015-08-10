getEventsWithState = (targetState, user, callback) ->
  # Maps event_id to list of labels
  label_map = {}
  user.getLabels().then (all_labels) ->
    for label in all_labels
      id = label.EventId
      if id of label_map
        label_map[id].push label.to_json()
      else
        label_map[id] = [label.to_json()]
    return user.getEvents({where: {state: targetState}})
  .then (events) ->
    for e in events
      e.decrypt()
    events = (e.to_json() for e in events)
    for event in events
      if event.id of label_map
        event.labels = label_map[event.id]
      else
        event.labels = []
    callback null, events
  .catch (err) ->
    callback err

exports.get_index = (req, res) ->
  renderDict = {
    user: req.user
  }
  if req.user
    getEventsWithState 'active', req.user, (error, events) ->
      if error
        console.log error
      renderDict.title = 'Thoughts'
      renderDict.state = JSON.stringify {
        events
        appType: 'active'
      }
      res.render 'index', renderDict
  else
    renderDict.title = 'Welcome'
    res.render 'index', renderDict

exports.get_archive = (req, res) ->
  renderDict = {
    user: req.user
    title: 'Archive'
  }
  getEventsWithState 'archived', req.user, (error, events) ->
    if error
      console.log error
    renderDict.state = JSON.stringify {
      events
      appType: 'active'
    }

    res.render 'archive/archive', renderDict
