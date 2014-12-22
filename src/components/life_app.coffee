React = require 'react'
moment = require 'moment'

# Structure:
# LifeApp (which is the timeline)
#   - Maintains a list of day headers
#   - Maintains a list of events

LifeApp = React.createClass
  displayName: 'Selector'
  getInitialState: (props) ->
    props = props || @props

    {events, headers} = @processEvents(props.events)

    return {
      events, headers
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  componentDidMount: () ->
    # TODO: add listeners and stuff here that we might want
    console.log @state

  render: () ->
    objects = @getAllTimelineObjects()
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"}, objects)

  sortEvents: (events) ->
    # Sort all the events from newest to oldest
    events.sort (a, b) ->
      b.date.unix() - a.date.unix()

    # Iterate through all of the events and reverse each day (oldest to newest)
    i = 0
    current_date = d = events[0].rendered_date
    j = 1
    sort_function = (a, b) ->
      a.date.unix() - b.date.unix()
    new_events = []
    while j < events.length
      event = events[j]
      if event.rendered_date != current_date
        # Slice, reverse sort
        s = events.slice i, j
        s.sort sort_function
        new_events = new_events.concat new_events, s
        i = j
        current_date = event.rendered_date
      j++
    # After the loop, if i is still in the array, do it one more time
    if i < events.length
      s = events.slice i, j
      s.sort sort_function
      new_events = new_events.concat new_events, s

    return new_events

  processEvents: (events) ->
    # Takes in the events and returns a dict with events and headers, both in sorted order
    if events.length == 0
      return {events, headers: []}

    for event in events
      # Make sure all the dates are moments
      if not event.date._isAMomentObject?
        event.date = moment(event.date)
        date = event.date.format("MMMM D, YYYY")
        event.rendered_date = date

    events = @sortEvents events

    headers = {}
    header_list = []
    for event in events
      if event.rendered_date not of headers
        header_list.push {date: event.rendered_date}
        headers[event.rendered_date] = true
    return {events, headers: header_list}

  getAllTimelineObjects: () ->
    # Reads the events and headers off of state, orders them, and returns them
    {events, headers} = @state
    objects = []
    i = 0
    key = 0
    for header in headers
      objects.push React.createElement "div", {key}, JSON.stringify(header)
      key++
      while i < events.length and events[i].rendered_date == header.date
        objects.push React.createElement "div", {key}, JSON.stringify(events[i])
        i++
        key++

    return objects

module.exports = {LifeApp}