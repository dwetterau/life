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
    base_moment = moment()
    {objects, past_events, future_events} =
      @getAllTimelineObjects(events, headers, @getViewTimeRange(view_type, base_moment))

    return {
      events
      headers
      objects
      counter: 0
      in_edit: false
      view_type
      base_moment
      past_events
      future_events
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  componentDidUpdate: () ->
    if $("form#event_form").length
      # Scroll to the edit pane
      $('html, body').animate({
        scrollTop: Math.max(0, $("form#event_form").offset().top - 120)
      }, 1000);

  getNewObjects: (events) ->
    {events, headers} = @processEvents events
    new_state = @getAllTimelineObjects events, headers
    new_state.events = events
    new_state.headers = headers
    return new_state

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
    event_id = $(e.target).data('event_id')
    url = e.target.action
    # Note: this should be the only thing left that relies on there only being one event
    # in edit mode at a time.
    $.post url, {
      id: event_id
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
    if not event.id?
      # Remove the event, it doesn't have an id yet
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

  archiveEvent: (e) ->
    id = $(e.target).data('event_id')
    $.post '/event/archive', {
      id
    }, (body) =>
      if body.status != 'ok'
        console.error("Failed to archive event")
      index = -1
      events = (x for x in @state.events)
      for event, i in events
        if event.id == id
          index = i
          break
      if index == -1
        throw Error("Couldn't find event entering edit mode.")

      # Remove the event
      events.splice(index, 1)
      new_state = @getNewObjects events
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
      event.key = "event_" + event.id + "_" +
        utils.hash(event.detail + date + JSON.stringify(event.labels))
      event.labels = (l.name for l in event.labels)

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
    past_events = false
    future_events = false
    for header, j in headers
      if header.moment.unix() < view_time_range.start
        # Skip over all the events for this header that are out of the window
        while i < events.length and events[i].rendered_date == header.date
          past_events = true
          i++
        continue
      if header.moment.unix() >= view_time_range.end
        break
      objects.push {key: header.key, header, id: "header_" + j}
      while i < events.length and events[i].rendered_date == header.date
        event = events[i]
        object = {key: event.key, event, id: "event_" + event.id}

        if event.edit_mode
          object.submit_handler = @submitHandler
          object.cancel_handler = @cancelHandler
        else
          object.edit_handler = @beginEdit
          object.archive_handler = @archiveEvent
        objects.push object
        i++

    if i < events.length
      future_events = true

    return {objects, past_events, future_events}

  switchView: (view_type) ->
    if view_type == @state.view_type
      return
    view_time_range = @getViewTimeRange(view_type)
    new_state = @getAllTimelineObjects @state.events, @state.headers, view_time_range
    new_state.view_type = view_type
    @setState new_state

  changeTimeRange: (to_past) ->
    m = @state.base_moment
    if to_past
      m.subtract 1, @state.view_type
    else
      m.add 1, @state.view_type

    # Update the objects to fit in this range
    new_state = @getAllTimelineObjects(@state.events, @state.headers)
    new_state.base_moment = m
    @setState new_state

  getViewTimeRange: (view_type, base_moment) ->
    # Return the beginning and end time points as moments for the view type
    # @return {start: unix_timestamp, end: unix_timestamp}
    if not base_moment?
      m = @state.base_moment
    else
      m = base_moment
    format = "MM/DD/YYYY"
    if view_type == 'day'
      start = moment(m.format(format), format)
    else if view_type == 'week'
      start = moment(m.format(format), format).subtract(m.weekday(), 'day')
    else if view_type == 'month'
      start = moment(m.format("MM/1/YYYY"), format)
    end = moment(start).add(1, view_type)
    return {start: start.unix(), end: end.unix()}

  getNoObjectsHeader: () ->
    time_range = @getViewTimeRange(@state.view_type)
    start_moment = moment.unix(time_range.start)
    if @state.view_type == 'day'
      content = start_moment.format(RENDERED_DATE_FORMAT)
      subtext_ending = "day."
    else if @state.view_type == 'week'
      content = 'Week of ' + start_moment.format(RENDERED_DATE_FORMAT)
      subtext_ending = "week."
    else if @state.view_type == 'month'
      content = start_moment.format("MMMM, YYYY")
      subtext_ending = "month."
    return [
      React.createElement("div", {className: "header-tile", key: 'temp-header'},
        React.createElement("h4", {key: 'temp-header-content'}, content)
        React.createElement("i", {className: "text-center", key: 'temp-header-subtext'},
          "You have not recorded any events for this " + subtext_ending
        )
      )
    ]

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
      timeline = @getNoObjectsHeader()

    app_nav_props = () =>
      key: "top_app_nav"
      top: true
      switchView: @switchView
      changeTimeRange: @changeTimeRange
      addEvent: @addEvent
      past_events: @state.past_events
      future_events: @state.future_events

    app_array = [
      React.createElement(AppNavigation, app_nav_props())
      React.createElement("div",
        {key: "timeline", className: "col-sm-offset-2 col-sm-8"}, timeline)
    ]
    # TODO: Mess with this random constant
    if timeline_list.length > 3
      props = app_nav_props()
      props.key = "bottom_app_nav"
      props.top = false
      app_array.push React.createElement(AppNavigation, props)

    return React.createElement("div", null, app_array)

AppNavigation = React.createClass
  displayName: 'AppNavigation'

  switchView: (e) ->
    @props.switchView $(e.target).data('view')

  goToPast: (e) ->
    @props.changeTimeRange true

  goToFuture: (e) ->
    @props.changeTimeRange false

  getNavigationButtons: () ->
    href = 'javascript:void(0)'
    className = "navigation-button btn btn-default"
    disabled = {href, className: className + " disabled"}
    past_options = disabled
    future_options = disabled

    if @props.past_events
      past_options = {href, className, onClick: @goToPast}
    if @props.future_events
      future_options = {href, className, onClick: @goToFuture}

    # Note: order is reversed because floating to the right
    return [
      React.createElement("div", {key: 'future', className: "btn-group float-right"},
        React.createElement("a", future_options,
          React.createElement("i", className: "mdi-navigation-chevron-right")
        )
      )
      React.createElement("div", {key: 'past', className: "btn-group float-right"},
        React.createElement("a", past_options,
          React.createElement("i", className: "mdi-navigation-chevron-left")
        )
      )
    ]

  render: () ->
    navigation_buttons = @getNavigationButtons()
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
        }, "Time Range ",
          React.createElement("span", {className: "caret"})
        )
        React.createElement("ul", className: "dropdown-menu",
          React.createElement("li", null,
            React.createElement("a",
              {href, onClick: @switchView, 'data-view': 'day'}, 'Today')
          )
          React.createElement("li", null,
            React.createElement("a",
              {href, onClick: @switchView, 'data-view': 'week'}, 'This week')
          )
          React.createElement("li", null,
            React.createElement("a",
              {href, onClick: @switchView, 'data-view': 'month'}, 'This month')
          )
        )
      )
      navigation_buttons
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
      show_all_detail: true
    }
    initial.to_display = @prepareEvent(props.event, true)

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

  handleExpand: (e) ->
    @switchDetail()

  handleArchive: (e) ->
    @props.archive_handler e

  handleBeginEdit: (e) ->
    @props.edit_handler e

  render: () ->
    if @state.event.edit_mode
      return React.createElement(EditEvent, {
        id: @props.id, event: @state.event,
        submit_handler: @props.submit_handler, cancel_handler: @props.cancel_handler
      })
    else
      if @state.show_all_detail
        expand_class = "mdi-navigation-expand-less"
      else
        expand_class = "mdi-navigation-expand-more"

      return React.createElement("div", {className: "well", id: @props.id},
        React.createElement("div", {key: "arrow", className: "event-arrow"})
        React.createElement("div", {key: "buttons", className: "event-header"},
          React.createElement("i", {
            className: "mdi-content-archive", 'data-event_id': @state.event.id,
            onClick: @handleArchive
          })
          React.createElement("i", {
            className: "mdi-content-create", 'data-event_id': @state.event.id,
            onClick: @handleBeginEdit
          })
          React.createElement("i", {className: expand_class, onClick: @handleExpand})
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