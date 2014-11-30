exports.get_index = (req, res) ->
  render_dict = {
    user: req.user
    title: 'Home'
  }
  res.render 'index', render_dict
