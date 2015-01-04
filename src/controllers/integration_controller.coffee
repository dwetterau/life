exports.get_index = (req, res) ->
  # TODO: Retrieve the right state for the user
  state = {integrations: []}

  res.render 'integrations/integration_index', {
    title: 'Integrations'
    user: req.user
    state: JSON.stringify state
  }
