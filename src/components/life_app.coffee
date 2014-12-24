React = require 'react'
moment = require 'moment'
utils = require '../lib/utils'
{EditEvent} = require './edit_event'

# Structure:
# LifeApp (which is the timeline)
#   - Maintains a list of day headers
#   - Maintains a list of events

LifeApp = React.createClass
  displayName: 'LifeApp'
  getInitialState: (props) ->
    props = props || @props

    @initializeEvents(props.events)
    {events, headers} = @processEvents(props.events)
    objects = @getAllTimelineObjects(events, headers)

    return {
      events
      headers
      objects
      timeline_hover_y: -1000
      counter: 0
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  componentDidMount: () ->
    $("div#timeline-bar").mousemove (event) =>
      if event.target.id == 'timeline-bar'
        @setState({timeline_hover_y: event.offsetY})
      else if event.target.id == 'timeline-hover'
        # add the offset - 6 to the current offset
        timeline_hover_y = @state.timeline_hover_y + (event.offsetY - 6)
        @setState({timeline_hover_y})

    $("div#timeline-bar").mouseout () =>
      @setState({timeline_hover_y: -1000})

    $("div#timeline-hover").click (event) =>
      # We know the position in pixels of the click
      y = @state.timeline_hover_y
      new_date = @clickNear y

      # Make the new event
      event = {
        date: new_date
        rendered_date: new_date.format("MMMM D, YYYY")
        edit_mode: true
        detail: ""
        key: @state.counter
      }
      @insertEventAt new_date, event

  clickNear: (y) ->
    # Determine the object being hovered nearest
    objects = @getAllTimelineObjects(@state.events, @state.headers)
    traversed = 0
    for object in objects
      traversed += $("#" + object.id).outerHeight()
      if traversed > y
        inside_object = object
        break
    if not inside_object?
      throw Error("Didn't click near an event")

    if inside_object.header?
      return inside_object.header.moment
    else if inside_object.event?
      return inside_object.event.date
    throw Error("Unknown element type")

  insertEventAt: (date, event) ->
    target = 0
    for e, index in @state.events
      if e.date.unix() < date.unix()
        target = index
        break

    events = (x for x in @state.events)
    events.splice(target, 0, event)
    {events, headers} = @processEvents events
    @setState({
      events, headers, objects: @getAllTimelineObjects(events, headers),
      counter: @state.counter + 1
    })

  sortEvents: (events) ->
    # Sort all the events from newest to oldest
    events.sort (a, b) ->
      b.date.unix() - a.date.unix()

    return events

  initializeEvents: (events) ->
    for event in events
      event.date = moment.utc(event.date).local()
      date = event.date.format("MMMM D, YYYY")
      event.rendered_date = date
      event.key = "event:" + date + utils.hash(event.detail)

  processEvents: (events) ->
    # Takes in the events and returns a dict with events and headers, both in sorted order
    if events.length == 0
      return {events, headers: []}

    events = @sortEvents events

    headers = {}
    header_list = []
    for event in events
      if event.rendered_date not of headers
        header_list.push {
          date: event.rendered_date,
          moment: moment(event.rendered_date, "MMMM D, YYYY")
          key: "header:" + event.rendered_date
        }
        headers[event.rendered_date] = true
    return {events, headers: header_list}

  getAllTimelineObjects: (events, headers) ->
    # Reads the events and headers off of state, orders them, and returns them
    objects = []
    i = 0
    for header, j in headers
      objects.push {key: header.key, header, id: "header_" + j}
      while i < events.length and events[i].rendered_date == header.date
        event = events[i]
        objects.push {key: event.key, event, id: "event_" + i}
        i++

    return objects

  render: () ->
    timeline_list = []
    for object in @state.objects
      if object.header?
        timeline_list.push React.createElement(Header, object)
      else if object.event
        timeline_list.push React.createElement(EventTile, object)

    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"},
      React.createElement(TimelineBar, {y: @state.timeline_hover_y}),
      React.createElement("div", null, timeline_list)
    )

Header = React.createClass
  displayName: 'Header'
  render: () ->
    return React.createElement("div", {className: 'header-tile', id: @props.id},
      React.createElement("h4", null, @props.header.date)
    )

EventTile = React.createClass
  displayName: 'EventTile'

  getInitialState: (props) ->
    props = props || @props

    initial = {
      event: props.event
      show_all_detail: false
    }
    initial.to_display = @prepareEvent(props.event, false)

    return initial

  getEventDetail: (event, show_all) ->
    if show_all
      return event.detail
    else
      element = $('<div>').html(event.detail)
      first_child = element.children().get(0)
      return if first_child? then first_child.innerHTML else ""

  prepareEvent: (event, show_all) ->
    return {
      date: event.date.format('h:mm a')
      detail: @getEventDetail(event, show_all)
    }

  switchDetail: () ->
    show_all_detail = not @state.show_all_detail
    to_display = @prepareEvent(@state.event, show_all_detail)

    # Trigger the render
    @setState {to_display, show_all_detail}

  handleClick: (e) ->
    @switchDetail()
    e.stopPropagation()

  render: () ->
    if @state.event.edit_mode
      return React.createElement(EditEvent, {id: @props.id, event: @state.event})
    else
      return React.createElement("div", {className: "well", id: @props.id, onClick: @handleClick},
        React.createElement("div", {className: "event-arrow"})
        React.createElement("div", {className: "event-date"}, @state.to_display.date)
        React.createElement("div", {
          className: "event-detail",
          dangerouslySetInnerHTML: {__html: @state.to_display.detail}
        })
      )

TimelineBar = React.createClass
  displayName: 'TimelineBar'
  render: () ->
    top = @props.y - 6
    return React.createElement("div", {id: "timeline-bar"},
      React.createElement("div", {id: "timeline-hover", style: {top}}, "+")
    )

module.exports = {LifeApp}