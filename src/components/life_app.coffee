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
    {objects, past_events, future_events, labels} =
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
      labels
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  componentDidUpdate: () ->
    if $("form#event_form").length and @inlineEditing(false)
      @scrollToEdit()

  scrollToEdit: () ->
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
    # Don't add another if we are editing something
    if @state.in_edit
      return
    new_date = moment()
    # Make the new event
    event = {
      date: new_date
      rendered_date: new_date.format(RENDERED_DATE_FORMAT)
      edit_mode: true
      detail: ""
      key: TEMP_EVENT_PREFIX + @state.counter
      temp_event: true
    }
    new_state = {
      temp_event: @createEventTileObject(event)
      counter: @state.counter + 1
      in_edit: true
    }
    @setState new_state

  submitHandler: (e, url) ->
    key =  e.key
    event_id = e.id
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

        if @inlineEditing(false)
          # If we were editing inline, remove the old event
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
        new_state.temp_event = null

        @setState new_state

  cancelHandler: (e) ->
    # If the event was a temp event, just delete it
    if not @inlineEditing()
      new_state = {
        temp_event: null
        in_edit: false
      }
      @setState new_state
    else
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

  grabEventIdAndRemove: (endpoint, e) ->
    id = $(e.target).data('event_id')
    $.post endpoint, {
      id
    }, (body) =>
      if body.status != 'ok'
        console.error("Bad call to endpoint")
      index = -1
      events = (x for x in @state.events)
      for event, i in events
        if event.id == id
          index = i
          break
      if index == -1
        throw Error("Couldn't find event that was modified")

      # Remove the event
      events.splice(index, 1)
      new_state = @getNewObjects events
      @setState new_state

  archiveEvent: (e) ->
    @grabEventIdAndRemove '/event/archive', e

  restoreEvent: (e) ->
    @grabEventIdAndRemove '/event/restore', e

  deleteEvent: (e) ->
    @grabEventIdAndRemove '/event/delete', e

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

  createEventTileObject: (event) ->
    object = {
      key: event.key
      event
      id: "event_" + event.id
      type: event.state
      labels: @state.labels
    }

    if event.edit_mode
      object.submit_handler = @submitHandler
      object.cancel_handler = @cancelHandler
    else
      if event.state == 'active'
        object.edit_handler = @beginEdit
        object.archive_handler = @archiveEvent
      else if event.state == 'archived'
        object.restoreHandler = @restoreEvent
        object.deleteHandler = @deleteEvent
    return object

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
        objects.push @createEventTileObject(events[i])
        i++

    if i < events.length
      future_events = true

    labels = {}
    for event in events
      for label in event.labels
        if label of labels
          labels[label].push event.id
        else
          labels[label] = [event.id]

    return {objects, past_events, future_events, labels}

  # Returns if we are editing an event inline or not. If so, we shouldn't allow view changes.
  # TODO: Make this display a warning if it returns false and displayError is true.
  inlineEditing: (displayError) ->
    return @state.in_edit and not @state.temp_event?

  switchView: (view_type) ->
    if @inlineEditing(true)
      return
    if view_type == @state.view_type
      return
    view_time_range = @getViewTimeRange(view_type)
    new_state = @getAllTimelineObjects @state.events, @state.headers, view_time_range
    new_state.view_type = view_type
    @setState new_state

  changeTimeRange: (to_past) ->
    if @inlineEditing(true)
      return
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

    app_array = [React.createElement(AppNavigation, app_nav_props())]
    if @state.temp_event?
      app_array.push React.createElement(
        "div",
        {key: "temp-event-container", className: "container col-sm-offset-2 col-sm-8"},
        React.createElement(EventTile, @state.temp_event)
      )
    app_array.push React.createElement("div",
      {key: "timeline", className: "col-sm-offset-2 col-sm-8"}, timeline)

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

    return [
      React.createElement("div", {key: 'past', className: "btn-group"},
        React.createElement("a", past_options,
          React.createElement("i", className: "mdi-navigation-chevron-left")
        )
      )
      React.createElement("div", {key: 'future', className: "btn-group"},
        React.createElement("a", future_options,
          React.createElement("i", className: "mdi-navigation-chevron-right")
        )
      )
    ]

  getViewChangeButton: () ->
    href = 'javascript:void(0)'
    React.createElement("div", {key: "view-button", className: "btn-group"},
      React.createElement("a", {
        className: "btn btn-material-indigo dropdown-toggle small-btn"
        'data-toggle': "dropdown"
      }, "Time Range ",
        React.createElement("span", {className: "caret"})
      )
      React.createElement("ul", className: "dropdown-menu small-menu",
        React.createElement("li", null,
          React.createElement("a",
            {href, onClick: @switchView, 'data-view': 'day'}, 'One day')
        )
        React.createElement("li", null,
          React.createElement("a",
            {href, onClick: @switchView, 'data-view': 'week'}, 'One week')
        )
        React.createElement("li", null,
          React.createElement("a",
            {href, onClick: @switchView, 'data-view': 'month'}, 'One month')
        )
      )
    )

  getAddEventButton: () ->
    href = 'javascript:void(0)'
    React.createElement("div", {key: "add-event-button", className: "btn-group"},
      React.createElement(
        "a", {href, className: "btn btn-success small-btn", onClick: @props.addEvent}, 'Add Event')
    )

  render: () ->
    navigation_buttons = @getNavigationButtons()
    right_side = [navigation_buttons]

    left_side = [@getAddEventButton()]
    if @props.top
      left_side.push @getViewChangeButton()

    # View changes
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8"},
      React.createElement("div", {className: "nav-buttons-left-side"}
        left_side
      )
      React.createElement("div", {className: "nav-buttons-right-side"},
        right_side
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
      type: props.type
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

  handleArchive: (e) ->
    @props.archive_handler e

  handleRestore: (e) ->
    @props.restoreHandler e

  handleDelete: (e) ->
    @props.deleteHandler e

  handleBeginEdit: (e) ->
    @props.edit_handler e

  render: () ->
    if @state.event.edit_mode
      return React.createElement(EditEvent, {
        id: @props.id, event: @state.event, labels: @props.labels,
        submit_handler: @props.submit_handler, cancel_handler: @props.cancel_handler
      })
    else
      tileOptions =
        handleEventExpand: @switchDetail
        handleArchive: @handleArchive
        handleRestore: @handleRestore
        handleDelete: @handleDelete
        handleBeginEdit: @handleBeginEdit
        eventShowAll: @state.show_all_detail
        type: @props.type
        eventId: @state.event.id

      return React.createElement("div", {className: "well", id: @props.id},
        React.createElement("div", {key: "arrow", className: "event-arrow"})
        React.createElement("div", {key: "date", className: "event-date"},
          @state.to_display.date,
          React.createElement(EventTileOptions, tileOptions)
        )
        React.createElement("div", {
          className: "event-detail", key: "detail"
          dangerouslySetInnerHTML: {__html: @state.to_display.detail}
        })
      )

EventTileOptions = React.createClass
  displayName: "EventTileOptions"

  getInitialState: () ->
    return {
      optionsExpanded: false
    }

  handleExpand: (e) ->
    @setState optionsExpanded: not @state.optionsExpanded
    e.preventDefault()
    e.stopPropagation()
    return false

  handleEventExpand: (e) ->
    @props.handleEventExpand e

  handleArchive: (e) ->
    if @props.type != 'active'
      throw Error "Can't archive non-active event"
    @props.handleArchive e

  handleRestore: (e) ->
    if @props.type != 'archived'
      throw Error "Can't restore non-archived event"
    @props.handleRestore e

  handleDelete: (e) ->
    if @props.type != 'archived'
      throw Error "Can't delete non-archived event"
    @props.handleDelete e

  handleBeginEdit: (e) ->
    if @props.type != 'active'
      throw Error "Can't edit non-active event"
    @props.handleBeginEdit e

  getOptionsExpandClass: () ->
    return "mdi-navigation-more-horiz"

  getEventExpandClass: () ->
    if @props.eventShowAll
      return "mdi-navigation-expand-less"
    else
      return "mdi-navigation-expand-more"

  renderCollapsed: () ->
    optionsClass = @getOptionsExpandClass()

    return React.createElement("div", className: "event-header",
      React.createElement("i", {
        className: optionsClass, onClick: @handleExpand
      })
    )

  renderExpanded: (type) ->
    eventExpandClass = @getEventExpandClass()
    optionsClass = @getOptionsExpandClass()
    if type == 'active'
      buttons = [
        React.createElement("i", {
          key: "archive"
          className: "mdi-content-archive", 'data-event_id': @props.eventId,
          onClick: @handleArchive
        })
        React.createElement("i", {
          key: "edit"
          className: "mdi-content-create", 'data-event_id': @props.eventId,
          onClick: @handleBeginEdit
        })
      ]
    else if type == 'archived'
      buttons = [
        React.createElement("i", {
          key: "restore"
          className: "mdi-content-reply", 'data-event_id': @props.eventId,
          onClick: @handleRestore
        })
        React.createElement("i", {
          key: "delete"
          className: "mdi-content-clear", 'data-event_id': @props.eventId,
          onClick: @handleDelete
        })
      ]
    else
      throw Error "Unknown event type"

    buttons = buttons.concat [
      React.createElement("i",
        {key: "ee", className: eventExpandClass, onClick: @handleEventExpand})
      React.createElement("i", {key: "oe", className: optionsClass, onClick: @handleExpand})
    ]

    return React.createElement("div", {key: "buttons", className: "event-header"}, buttons)

  render: () ->
    if not @state.optionsExpanded
      return @renderCollapsed()
    return @renderExpanded @props.type

TimelineBar = React.createClass
  displayName: 'TimelineBar'
  render: () ->
    return React.createElement("div", {id: "timeline-bar"})

module.exports = {LifeApp}