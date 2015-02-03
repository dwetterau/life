React = require 'react'

# This dependency will be removed in react v1.0
injectTapEventPlugin = require 'react-tap-event-plugin'
{Paper, RaisedButton, Input} = require 'material-ui'

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
      inputs.push React.createElement Input, inputObject
    return inputs

  render: () ->
    <div className="container">
      <div className="page-header">
        <h1>{@props.pageHeader}</h1>
      </div>
      <Paper className="white-paper">
        <div className="form-container">
          <form className="form-horizontal" action={@props.action} method="POST">
            {@getInputs @props.inputs}
            <RaisedButton type="submit" label={@props.submitLabel} primary=true />
          </form>
        </div>
      </Paper>
    </div>

module.exports = {FormPage}