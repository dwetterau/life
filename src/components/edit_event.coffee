React = require 'react'
moment = require 'moment'
{Selector} = require './time_selector'
{Editor} = require './quill_editor'

EditEvent = React.createClass
  displayName: 'EditEvent'

  getInitialState: (props) ->
    props = props || @props

    {event} = props

    return {
      event
      action: '/event/add'
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  render: () ->
    return React.createElement("div", {className: 'well'},
      React.createElement("form", {
        id: "event_form",
        action: @state.action
        method: "POST"
      },
        # Elements for the time and date selection
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement(Selector, {date: @state.event.date})
        )

        # Elements for the detail editing
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement(Editor, {detail: @state.event.detail})
        )

        # Elements for the labels (WIP)
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement("input", {
            className: "form-control floating-label"
            type: "text"
            name: "labels"
            id: "labels"
            placeholder: "Labels"
          })
        )

        # Elements for the submit button
        React.createElement("div", {className: "form-group form-group-material-indigo"},
          React.createElement("button", {className: "btn btn-success no-margin", type: "submit"},
            React.createElement("span", {className: "ion-person-add"}, "Done")
          )
        )
      )
    )

module.exports = {EditEvent}
