React = require 'react'
moment = require 'moment'
{Selector} = require './time_selector'
{Editor} = require './editor'

EditEvent = React.createClass
  displayName: 'EditEvent'

  getInitialState: (props) ->
    props = props || @props

    action = if props.event.id? then '/event/update' else '/event/add'

    return {
      event: props.event
      action
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  getLabelList: () ->
    ({value: l} for l of @props.labels)

  componentDidMount: () ->
    engine = new Bloodhound({
      local: @getLabelList()
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.value)
      queryTokenizer: Bloodhound.tokenizers.whitespace
    })
    engine.initialize()
    $("input#labels").tokenfield({
      delay: 100
      delimiter: " "
      createTokensOnBlur: true
      typeahead: [null, {source: engine.ttAdapter()}]
    }).on 'tokenfield:createtoken', (e) ->
      e.attrs.value = e.attrs.value.toLowerCase()

  convertToString: (array) ->
    if not array?
      return ""
    array.sort()
    return array.join(" ")

  handleSubmit: () ->
    @props.submit_handler @state.event, @state.action

  render: () ->
    return React.createElement("div", {className: 'well'},
      React.createElement("form", {
        id: "event_form",
      },
        # Elements for the time and date selection
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement(Selector, {date: @state.event.date})
        )

        # Elements for the detail editing
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement(Editor, {detail: @state.event.detail})
        )
      )

      # Elements for the labels
      React.createElement("div", {className: "form-group"},
        React.createElement("input", {
          type: "text"
          name: "labels"
          id: "labels"
          placeholder: "Enter labels..."
          defaultValue: @convertToString(@state.event.labels)
        })
      )

      # Elements for the submit button
      React.createElement("div", {className: "form-group form-group-material-indigo text-right"},
        React.createElement("button",
          {className: "btn btn-danger submit-button", onClick: @props.cancel_handler},
          React.createElement("span", null, "Cancel")
        )
        React.createElement("button",
          {className: "btn btn-success submit-button", onClick: @handleSubmit},
          React.createElement("span", null, "Done")
        )
      )
    )

module.exports = {EditEvent}
