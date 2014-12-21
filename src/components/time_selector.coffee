React = require 'react'

DaySelector = React.createClass
  displayName: "DaySelector"
  render: () ->
    options = (React.createElement("option", null, option) for option in @.props.options)

    return React.createElement("div", {className: "time"},
      React.createElement("select", {className: "form-control"}, options)
    )

TimeSelector = React.createClass
  displayName: "TimeSelector"
  render: () ->
    options = (React.createElement("option", null, option) for option in @.props.options)

    return React.createElement("div", {className: "time"},
      React.createElement("select", {className: "form-control"}, options)
    )

Selector = React.createClass
  displayName: 'Selector'
  render: () ->
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"},
      React.createElement(DaySelector, {options: ['Today', 'Yesterday', 'Another day']}),
      React.createElement(TimeSelector, {options: ['right now', 'another time']})
    )

module.exports = {DaySelector, TimeSelector, Selector}
