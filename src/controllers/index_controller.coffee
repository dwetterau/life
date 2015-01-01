exports.get_index = (req, res) ->
  render_dict = {
    user: req.user
    title: 'Home'
  }
  if req.user
    # Maps event_id to list of labels
    label_map = {}
    req.user.getLabels().success (all_labels) ->
      for label in all_labels
        id = label.EventId
        if id of label_map
          label_map[id].push label.to_json()
        else
          label_map[id] = [label.to_json()]
      return req.user.getEvents()
    .success (events) ->
      events = (e.to_json() for e in events when e.state == 'active')
      for event in events
        if event.id of label_map
          event.labels = label_map[event.id]
        else
          event.labels = []
      render_dict.state = JSON.stringify(events)
      res.render 'index', render_dict
  else
    res.render 'index', render_dict
