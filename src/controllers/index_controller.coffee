getEventsWithState = (targetState, user, callback) ->
  # Maps event_id to list of labels
  label_map = {}
  user.getLabels().success (all_labels) ->
    for label in all_labels
      id = label.EventId
      if id of label_map
        label_map[id].push label.to_json()
      else
        label_map[id] = [label.to_json()]
    return user.getEvents({where: {state: targetState}})
  .success (events) ->
    for e in events
      e.decrypt()
    events = (e.to_json() for e in events)
    for event in events
      if event.id of label_map
        event.labels = label_map[event.id]
      else
        event.labels = []
    callback null, JSON.stringify(events)
  .catch (err) ->
    callback err

exports.get_index = (req, res) ->
  render_dict = {
    user: req.user
  }
  if req.user
    getEventsWithState 'active', req.user, (error, state) ->
      if error
        console.log error
      render_dict.title = 'Timeline'
      render_dict.state = state
      res.render 'index', render_dict
  else
    render_dict.title = 'Welcome'
    res.render 'index', render_dict

exports.get_archive = (req, res) ->
  renderDict = {
    user: req.user
    title: 'Archive'
  }
  getEventsWithState 'archived', req.user, (error, state) ->
    if error
      console.log error
    renderDict.state = state
    res.render 'archive/archive', renderDict
