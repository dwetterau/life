React = require 'react'

# This dependency will be removed in react v1.0
injectTapEventPlugin = require 'react-tap-event-plugin'
mui = require 'material-ui'

###
  Expected props:
  - pageHeader: The header of the page
  - action: The action url for the form
  - inputs: an array of inputObjects
  - submitLabel: the label for the submit button
###
FormPage = React.createClass
  displayName: 'FormPage'
  componentDidMount: () ->
    injectTapEventPlugin()

  getInputs: (inputObjects) ->
    inputs = []
    for inputObject in inputObjects
      inputs.push React.createElement mui.Input, inputObject
    return inputs

  render: () ->
    React.createElement "div", {className: "container"},
      React.createElement "div", {className: "page-header"},
        React.createElement "h1", null, @props.pageHeader
      React.createElement mui.Paper, {className: "white-paper"},
        React.createElement "div", {className: "form-container"},
          React.createElement "form",
            {className: "form-horizontal", action: @props.action, method: 'POST'},
            @getInputs(@props.inputs)
            React.createElement mui.RaisedButton,
              {type: "submit", label: @props.submitLabel, primary: true}

module.exports = {FormPage}