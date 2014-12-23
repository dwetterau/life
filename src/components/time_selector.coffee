React = require 'react'
moment = require 'moment'

DaySelector = React.createClass
  displayName: "DaySelector"
  months: ['January', 'February', 'March', 'April', 'May', 'June', 'July',
               'August', 'September', 'October', 'November', 'December']
  days: [1..31]
  years: (x for x in [1970..2014].reverse())
  day_suffixes: ['st', 'nd', 'rd', 'th']

  getInitialState: (props) ->
    props = @props || props

    return {
      date: props.date
      date_suffix: @getDaySuffixIndex(props.date.date())
    }

  handleChange: (event) ->
    id = event.target.id
    i = event.target.selectedIndex
    state = @state
    selections = @getSelectionWithDate()

    if id == 'months'
      # if we are changing to a month with fewer days,
      # we may need to adjust the day as well
      state.date.set('month', @months[i])
      if i != selections[0]
        new_num_days = state.date.daysInMonth()
        if @days[selections[1]] > new_num_days
          state.date_suffix = @getDaySuffixIndex(new_num_days)
    else if id == 'days'
      state.date.set('date', @days[i])
      state.date_suffix = @getDaySuffixIndex(@days[i])
    else if id == 'years'
      state.date.set('year', @years[i])
      # Handle the case from switching from Feb. 29th to not a leap year
      if i != selections[2]
        if @days[selections[1]] != state.date.date()
          state.date_suffix = @getDaySuffixIndex(1)

    @props.cb(state)

  getDaySuffixIndex: (day) ->
    if (day <= 3 or (day > 20 and day % 10 <= 3)) and day % 10 > 0
      return (day - 1) % 10
    else
      return 3

  getSelectionWithDate: () ->
    # Returns an array of the selections in month, days, and years
    m = @state.date
    month = parseInt(m.format("MM")) - 1
    days = m.date() - 1
    years = 2014 - m.year()

    return [month, days, years]


  render: () ->
    selections = @getSelectionWithDate()
    day_suffix = @day_suffixes[@state.date_suffix]
    days_in_month = @state.date.daysInMonth()

    months = (React.createElement("option", {key: i}, month) for month, i in @months)
    days = (React.createElement(
      "option", {key: i}, day) for day, i in @days when i < days_in_month)
    years = (React.createElement("option", {key: i}, year) for year, i in @years)

    return React.createElement("div", className: "time",
      React.createElement("div", {className: 'selector'},
        React.createElement("select", {
          id: "months"
          className: "form-control selector"
          value: @months[selections[0]]
          onChange: @handleChange
        }, months)
      )
      React.createElement("div", {className: 'selector'},
        React.createElement("select", {
          id: "days"
          className: "form-control selector"
          value: @days[selections[1]]
          onChange: @handleChange
        }, days)
      )
      React.createElement("span", {className: 'time'}, day_suffix, ", ")
      React.createElement("div", {className: 'selector'},
        React.createElement("select", {
          id: "years"
          className: "form-control selector"
          value: @years[selections[2]]
          onChange: @handleChange
        }, years)
      )
    )

TimeSelector = React.createClass
  displayName: "TimeSelector"
  hours: [1..12]
  minutes: ['00', '05', '10', '15', '20', '25', '30', '35', '40', '45', '50', '55']
  periods: ['AM', 'PM']

  getInitialState: (props) ->
    props = @props || props

    return {
      date: props.date
    }

  handleChange: (event) ->
    id = event.target.id
    i = event.target.selectedIndex
    selections = @getSelectionWithDate()
    state = @state
    if id == 'hours'
      hour = (if selections[2] == 0 then 0 else 12) + (@hours[i] % 12)
      state.date.set('hour', hour)
    else if id == 'minutes'
      minute = @minutes[i]
      state.date.set('minute', minute)
    else if id == 'periods'
      if selections[2] == i
        return
      hour = state.date.hour()
      if i == 0
        # Just switched from PM to AM, subtract 12 hours
        state.date.set('hour', hour - 12)
      else
        state.date.set('hour', hour + 12)
    @props.cb(state)

  getSelectionWithDate: () ->
    # Returns hours, minutes, period
    m = @state.date
    hour = parseInt(m.format('hh')) - 1
    minute = Math.floor(m.minute() / 5)
    period = if m.hour() >= 12 then 1 else 0
    return [hour, minute, period]

  render: () ->
    selections = @getSelectionWithDate()

    hours = (React.createElement("option", {key: i}, hour) for hour, i in @hours)
    minutes = (React.createElement("option", {key: i}, minute) for minute, i in @minutes)
    periods = (React.createElement("option", {key: i}, period) for period, i in @periods)

    return React.createElement("div", className: "time", onChange: @handleChange,
      React.createElement("div", {className: 'selector'},
        React.createElement("select", {
          id: "hours"
          className: "form-control selector"
          value: @hours[selections[0]]
          onChange: @handleChange
        }, hours)
      )
      React.createElement("span", null, ":")
      React.createElement("div", {className: 'selector'},
        React.createElement("select", {
          id: "minutes"
          className: "form-control selector"
          value: @minutes[selections[1]]
          onChange: @handleChange
        }, minutes)
      )
      React.createElement("div", {className: 'selector'},
        React.createElement("select", {
          id: "periods"
          className: "form-control selector"
          value: @periods[selections[2]]
          onChange: @handleChange
        }, periods)
      )
    )

Selector = React.createClass
  displayName: 'Selector'
  getInitialState: (props) ->
    props = props || @props

    return {
      date: props.date
    }

  updateParentState: (new_state) ->
    @setState(new_state)

  render: () ->
    date = moment(@state.date).utc().toString()

    return React.createElement("div", null,
      React.createElement(TimeSelector,
        {className: "time", date: @state.date, cb: @updateParentState})
      React.createElement("span", {className: "time"}, "on")
      React.createElement(DaySelector,
        {className: "time", date: @state.date, cb: @updateParentState})
      React.createElement("input", {id: "date", name: "date", type: "hidden", value: date})
    )

module.exports = {Selector}
