React = require 'react'

ALL_INTEGRATIONS = {dropbox: 1}

IntegrationMenu = React.createClass
  displayName: 'IntegrationMenu'
  getInitialState: (props) ->
    props = props || @props

    return {
      integrations: @props.integrations
    }

  # TODO: Figure out where to put these in a more central location
  dropboxConnectHandler: (e) ->


  # A function of state that returns the rendered modules in the right array
  getModules: () ->
    active = (@renderModule(m) for m of ALL_INTEGRATIONS when m of @props.integrations)
    inactive = (@renderModule(m) for m of ALL_INTEGRATIONS when m not of @props.integrations)

    if active.length
      active.unshift @getModuleHeader(true)
    if inactive.length
      inactive.unshift @getModuleHeader(false)

    return {active, inactive}

  getModuleHeader: (active) ->
    if active
      text = "Active"
    else
      text = "Inactive"
    text += " modules"
    return React.createElement("h4", {key: text + "header"}, text)

  renderModule: (type) ->
    switch type
      when "dropbox"
        return React.createElement(DropboxIntegrationModule,
          {key: type, active: type of @state.integrations, connectHandler: @dropboxConnectHandler}
        )
      else throw Error("Unknown module type")

  render: () ->
    {active, inactive} = @getModules()
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"},
      active, inactive
    )


DropboxIntegrationModule = React.createClass
  displayName: "DropboxIntegrationModule"
  render: () ->
    dict = {
      className: "dropbox-module module"
    }
    if not @props.active
      dict.onClick = @props.connectHandler
      dict.className += " module-inactive"
    return React.createElement("div", dict,
      React.createElement("img", {src: "/images/dropbox.png"})
    )


module.exports = {IntegrationMenu}