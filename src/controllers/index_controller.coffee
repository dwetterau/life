exports.get_index = (req, res) ->
  render_dict = {
    user: req.user
    title: 'Home'
  }
  if req.user
    req.user.getEvents().success (events) ->
      events = (e.to_json() for e in events when e.state == 'active')
      render_dict.state = JSON.stringify(events)
      res.render 'index', render_dict
  else
    res.render 'index', render_dict
