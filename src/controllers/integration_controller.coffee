exports.get_index = (req, res) ->
  # TODO: Retrieve the right state for the user

  req.user.getIntegrations().success (retrievedIntegrations) ->
    integrations = {}
    for i in retrievedIntegrations
      integrations[i.type] = i.toJSON()
    res.render 'integrations/integration_index', {
      title: 'Integrations'
      user: req.user
      state: JSON.stringify {integrations}
    }
