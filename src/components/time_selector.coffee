React = require 'react'

DaySelector = React.createClass
  displayName: "DaySelector"
  getInitialState: () ->
    return {
      options: ['Today', 'Yesterday', 'Another time']
    }

  render: () ->
    options = (React.createElement("option", null, option) for option in @state.options)

    return React.createElement("div", {className: "time"},
      React.createElement("select", {className: "form-control"}, options)
    )

TimeSelector = React.createClass
  displayName: "TimeSelector"
  getInitialState: () ->
    return {
      options: ['right now', 'another time']
      hours: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']
      minutes: ['00', '05', '10', '15', '20', '25', '30', '35', '40', '45', '50', '55']
      periods: ['AM', 'PM']
    }


  render: () ->
    options = (React.createElement("option", null, option) for option in @state.options)
    hours = (React.createElement("option", null, hour) for hour in @state.hours)
    minutes = (React.createElement("option", null, minute) for minute in @state.minutes)
    periods = (React.createElement("option", null, period) for period in @state.periods)

    return React.createElement("div", className: "time",
      React.DOM.div({className: 'selector'},
        React.createElement("select", className: "form-control hour-selector", hours)
      )
      React.createElement("span", null, ":")
      React.DOM.div({className: 'selector'},
        React.createElement("select", className: "form-control minute-selector", minutes)
      )
      React.createElement("span", null, " ")
      React.DOM.div({className: 'selector'},
        React.createElement("select", className: "form-control period-selector", periods)
      )
    )

Selector = React.createClass
  displayName: 'Selector'
  render: () ->
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"},
      React.createElement(DaySelector, {className: "time"}),
      React.createElement(TimeSelector, {className: "time"})
    )

module.exports = {DaySelector, TimeSelector, Selector}
