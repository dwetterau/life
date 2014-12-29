React = require 'react'
moment = require 'moment'
utils = require '../lib/utils'
{EditEvent} = require './edit_event'

# Structure:
# LifeApp (which is the timeline)
#   - Maintains a list of day headers
#   - Maintains a list of events

RENDERED_DATE_FORMAT = "dddd, MMMM D, YYYY"
TEMP_EVENT_PREFIX = "TempEventKey"

LifeApp = React.createClass
  displayName: 'LifeApp'
  getInitialState: (props) ->
    props = props || @props

    @initializeEvents(props.events)
    {events, headers} = @processEvents(props.events)
    view_type = "day"
    objects = @getAllTimelineObjects(events, headers, @getViewTimeRange(view_type))

    return {
      events
      headers
      objects
      counter: 0
      in_edit: false
      view_type
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  componentDidUpdate: () ->
    if $("form#event_form").length
      # Scroll to the edit pane
      $('html, body').animate({
        scrollTop: $("form#event_form").offset().top
      }, 1000);

  getNewObjects: (events) ->
    {events, headers} = @processEvents events
    return {events, headers, objects: @getAllTimelineObjects events, headers}

  addEvent: () ->
    new_date = moment()
    # Make the new event
    event = {
      date: new_date
      rendered_date: new_date.format(RENDERED_DATE_FORMAT)
      edit_mode: true
      detail: ""
      key: TEMP_EVENT_PREFIX + @state.counter
    }
    events = (x for x in @state.events)
    events.push event
    new_state = @getNewObjects events
    new_state.counter = @state.counter + 1
    new_state.in_edit = true
    @setState new_state

  submitHandler: (e) ->
    key = $(e.target).data('event_key')
    url = e.target.action
    $.post url, {
      date: $('#date').val()
      detail: $('#detail').val()
      labels: $('#labels').val()
    },
    (body) =>
      if body.status == 'ok'
        # Remove the event edit, add in the real event
        new_event = body.new_event
        @initializeEvents([new_event])

        events = @state.events
        # Determine the index of the edit event
        index = -1
        for event, i in events
          if event.key == key
            index = i
            break
        if index == -1
          throw Error("Didn't find edit event")
        events.splice(index, 1)
        events.push new_event
        new_state = @getNewObjects events
        new_state.in_edit = false
        @setState new_state

    e.preventDefault()

  cancelHandler: (e) ->
    # Remove the event in edit mode
    i = -1
    events = (x for x in @state.events)
    for event, index in events
      if event.edit_mode
        i = index
        break
    if i == -1 or not @state.in_edit
      throw Error("Canceled when no event was being edited.")

    event = events[i]
    if event.key.indexOf(TEMP_EVENT_PREFIX) == 0
      # Remove the event
      events.splice(i, 1)
    else
      events[i].edit_mode = false

    new_state = @getNewObjects events
    new_state.in_edit = false
    @setState new_state

    # Don't let the form submit
    e.preventDefault()
    e.stopPropagation()

  beginEdit: (e) ->
    if @state.in_edit
      return
    id = $(e.target).data('event_id')
    index = -1
    events = (x for x in @state.events)
    for event, i in events
      if event.id == id
        index = i
        break
    if index == -1
      throw Error("Couldn't find event entering edit mode.")

    # Save the event's current state in event.old
    event.edit_mode = true
    new_state = @getNewObjects events
    new_state.in_edit = true
    @setState new_state

  sortEvents: (events) ->
    # Sort all the events from oldest to newest
    events.sort (a, b) ->
      a.date.unix() - b.date.unix()

    return events

  initializeEvents: (events) ->
    for event in events
      event.date = moment.utc(event.date).local()
      date = event.date.format(RENDERED_DATE_FORMAT)
      event.rendered_date = date
      event.key = "event_" + event.id

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
          moment: moment(event.rendered_date, RENDERED_DATE_FORMAT)
          key: "header_" + event.rendered_date
        }
        headers[event.rendered_date] = true
    return {events, headers: header_list}

  getAllTimelineObjects: (events, headers, view_time_range) ->
    if not view_time_range?
      view_time_range = @getViewTimeRange @state.view_type
    # Reads the events and headers off of state, orders them, and returns them
    objects = []
    i = 0
    for header, j in headers
      if header.moment.unix() < view_time_range.start
        # Skip over all the events for this header that are out of the window
        while i < events.length and events[i].rendered_date == header.date
          i++
        continue
      if header.moment.unix() >= view_time_range.end
        break
      objects.push {key: header.key, header, id: "header_" + j}
      while i < events.length and events[i].rendered_date == header.date
        event = events[i]
        objects.push {key: event.key, event, id: "event_" + event.id}
        if event.edit_mode
          objects[objects.length - 1].submit_handler = @submitHandler
          objects[objects.length - 1].cancel_handler = @cancelHandler
        else
          objects[objects.length - 1].edit_handler = @beginEdit
        i++

    return objects

  switchView: (view_type) ->
    if view_type == @state.view_type
      return
    view_time_range = @getViewTimeRange(view_type)
    objects = @getAllTimelineObjects @state.events, @state.headers, view_time_range
    @setState({view_type, objects})

  getViewTimeRange: (view_type) ->
    # Return the beginning and end time points as moments for the view type
    # @return {start: unix_timestamp, end: unix_timestamp}
    format = "MM/DD/YYYY"
    if view_type == 'day'
      start = moment(moment().format(format), format)
    else if view_type == 'week'
      start = moment(moment().format(format), format).subtract(moment().weekday(), 'day')
    else if view_type == 'month'
      start = moment(moment().format("MM/1/YYYY"), format)
    end = moment(start).add(1, view_type)
    return {start: start.unix(), end: end.unix()}

  render: () ->
    timeline_list = []
    for object in @state.objects
      if object.header?
        timeline_list.push React.createElement(Header, object)
      else if object.event?
        timeline_list.push React.createElement(EventTile, object)

    if timeline_list.length
      timeline = [
        React.createElement(TimelineBar, {key: "timeline-bar"})
        React.createElement("div", {key: "timeline-content"}, timeline_list)
      ]
    else
      timeline = React.createElement("i", {className: "text-center"},
        "You have not recorded any events for this time range"
      )

    return React.createElement("div", null
      React.createElement(AppNavigation, {switchView: @switchView, addEvent: @addEvent})
      React.createElement("div", {className: "col-sm-offset-2 col-sm-8"}, timeline)
    )

AppNavigation = React.createClass
  displayName: 'AppNavigation'

  switchView: (e) ->
    @props.switchView $(e.target).data('view')

  render: () ->
    # View changes
    href = 'javascript:void(0)'
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"},
      React.createElement("div", {key: "add-event-button", className: "btn-group"},
        React.createElement(
          "a", {href, className: "btn btn-success", onClick: @props.addEvent}, 'Add Event')
      )
      React.createElement("div", {key: "view-button", className: "btn-group float-right"},
        React.createElement("a", {
          className: "btn btn-material-indigo dropdown-toggle"
          'data-toggle': "dropdown"
        }, "View ",
          React.createElement("span", {className: "caret"})
        )
        React.createElement("ul", className: "dropdown-menu",
          React.createElement("li", null,
            React.createElement("a", {href, onClick: @switchView, 'data-view': 'day'}, 'Day')
          )
          React.createElement("li", null,
            React.createElement("a", {href, onClick: @switchView, 'data-view': 'week'}, 'Week')
          )
          React.createElement("li", null,
            React.createElement("a", {href, onClick: @switchView, 'data-view': 'month'}, 'Month')
          )
        )
      )
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

  handleBeginEdit: (e) ->
    @props.edit_handler e

  render: () ->
    if @state.event.edit_mode
      return React.createElement(EditEvent, {
        id: @props.id, event: @state.event,
        submit_handler: @props.submit_handler, cancel_handler: @props.cancel_handler
      })
    else
      return React.createElement("div", {className: "well", id: @props.id},
        React.createElement("div", {key: "arrow", className: "event-arrow"})
        React.createElement("div", {key: "buttons", className: "event-header"},
          React.createElement("i", {
            className: "mdi-content-create", 'data-event_id': @state.event.id,
            onClick: @handleBeginEdit
          })
        )
        React.createElement("div", {key: "date", className: "event-date"}, @state.to_display.date)
        React.createElement("div", {
          className: "event-detail", key: "detail"
          dangerouslySetInnerHTML: {__html: @state.to_display.detail}
        })
      )

TimelineBar = React.createClass
  displayName: 'TimelineBar'
  render: () ->
    return React.createElement("div", {id: "timeline-bar"})

module.exports = {LifeApp}