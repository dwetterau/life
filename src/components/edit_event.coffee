React = require 'react'
moment = require 'moment'
{Selector} = require './time_selector'
{Editor} = require './quill_editor'

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

  componentDidMount: () ->
    $("input#labels").tokenfield({
      # TODO: Add stuff to autocomplete (based on existing labels)
      delay: 100
      delimiter: " "
      createTokensOnBlur: true
    }).on 'tokenfield:createtoken', (e) ->
      e.attrs.value = e.attrs.value.toLowerCase()

  convertToString: (array) ->
    if not array?
      return ""
    array.sort()
    return array.join(" ")

  render: () ->
    return React.createElement("div", {className: 'well'},
      React.createElement("div",
        {className: if @state.event.temp_event then "" else "event-arrow"}
      )
      React.createElement("form", {
        id: "event_form",
        action: @state.action
        method: "POST"
        'data-event_key': @state.event.key
        'data-event_id': @state.event.id
        onSubmit: @props.submit_handler
      },
        # Elements for the time and date selection
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement(Selector, {date: @state.event.date})
        )

        # Elements for the detail editing
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement(Editor, {detail: @state.event.detail})
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
            React.createElement("span", {className: "ion-person-add"}, "Cancel")
          )
          React.createElement("button",
            {className: "btn btn-success submit-button", type: "submit"},
            React.createElement("span", {className: "ion-person-add"}, "Done")
          )
        )
      )
    )

module.exports = {EditEvent}
