React = require 'react'
moment = require 'moment'
utils = require '../lib/utils'
{EditEvent} = require './edit_event'
{Icon, FlatButton} = require 'material-ui'

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
    {events, headers, labels} = @processEvents(props.events)
    view_type = "day"
    base_moment = moment()
    {objects, someFiltered} =
      @getAllTimelineObjects(
        events, headers, labels, @getViewTimeRange(view_type, base_moment), []
      )

    return {
      appType: @props.appType
      events
      headers
      objects
      counter: 0
      in_edit: false
      view_type
      base_moment
      someFiltered
      labels
      labelFilter: []
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  componentDidUpdate: () ->
    if @state.in_edit
      @scrollToEdit()

  scrollToEdit: () ->
    # Scroll to the edit pane
    $('html, body').animate({
      scrollTop: Math.max(0, $("form#event_form").offset().top - 120)
    }, 1000);

  getNewObjects: (events) ->
    {events, headers, labels} = @processEvents events
    new_state = @getAllTimelineObjects events, headers, labels
    new_state.events = events
    new_state.headers = headers
    return new_state

  addEvent: () ->
    # Don't add another if we are editing something
    if @state.in_edit
      @throwAlreadyEditingError()
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
      temp_event: @createEventTileObject(event, @state.labels)
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
      @throwAlreadyEditingError()
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

    labels = {}
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

      event.labelLookupMap = {}
      # Compute all the labels
      for label in event.labels
        event.labelLookupMap[label] = true
        if label of labels
          labels[label].push event.id
        else
          labels[label] = [event.id]

    return {events, headers: header_list, labels}

  createEventTileObject: (event, allLabels) ->
    object = {
      key: event.key
      event
      id: "event_" + event.id
      type: event.state
      labels: allLabels
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

  getAllTimelineObjects: (events, headers, labels, view_time_range, labelFilter) ->
    if not view_time_range?
      view_time_range = @getViewTimeRange @state.view_type
    if not labelFilter?
      labelFilter = @state.labelFilter

    # Returns true if the event is filtered out because it doesn't have one of the
    # labels in the labelFilter
    filtered = (event) ->
      for label in labelFilter
        if label not of event.labelLookupMap
          return true
      return false

    # Note that it's okay to change events here because we don't output it
    events = (e for e in events when not filtered(e))

    # Reads the events and headers off of state, orders them, and returns them
    objects = []
    i = 0
    someFiltered = false
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
        objects.push @createEventTileObject(events[i], labels)
        i++
      # If the previous thing in objects is a header, the events have been filtered out
      if objects[objects.length - 1].header?
        someFiltered = true
        objects.pop()

    return {objects, someFiltered}

  throwAlreadyEditingError: () ->
    $.snackbar
      content: "Finish editing your event first!"
      timeout: 3000

  # Returns if we are editing an event inline or not. If so, we shouldn't allow view changes.
  inlineEditing: (displayError) ->
    inlineEditing = @state.in_edit and not @state.temp_event?
    if inlineEditing and displayError
      @throwAlreadyEditingError()
    return inlineEditing

  switchView: (view_type) ->
    if @inlineEditing(true)
      return
    if view_type == @state.view_type
      return
    view_time_range = @getViewTimeRange(view_type)
    new_state = @getAllTimelineObjects(
      @state.events, @state.headers, @state.labels, view_time_range
    )
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
    new_state = @getAllTimelineObjects(@state.events, @state.headers, @state.labels)
    new_state.base_moment = m
    @setState new_state

  resetTimeRange: () ->
    if @inlineEditing true
      return
    m = moment()
    @state.base_moment = m
    newState = @getAllTimelineObjects(@state.events, @state.headers, @state.labels)
    newState.base_moment = m
    @setState newState

  filterTokens: (filterTokens) ->
    if @inlineEditing(true)
      return
    if filterTokens is ''
      filterTokens = []
    else
      filterTokens = filterTokens.split(' ')
    new_state = @getAllTimelineObjects(
      @state.events, @state.headers, @state.labels, null, filterTokens
    )
    new_state.labelFilter = filterTokens
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
    else if view_type == 'year'
      start = moment(m.format("1/1/YYYY"), format)
    end = moment(start).add(1, view_type)
    return {start: start.unix(), end: end.unix()}

  getNoObjectsHeader: (prefix) ->
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
    else if @state.view_type == 'year'
      content = start_moment.format("YYYY")
      subtext_ending = "year."
    return [
      React.createElement("div", {className: "header-tile", key: 'temp-header'},
        React.createElement("h4", {key: 'temp-header-content'}, content)
        React.createElement("i", {className: "text-center", key: 'temp-header-subtext'},
          prefix + subtext_ending
        )
      )
    ]

  render: () ->
    timeline_list = []
    hasEvent = false
    for object in @state.objects
      if object.element?
        timeline_list.push object.element
      else if object.header?
        timeline_list.push React.createElement(Header, object)
      else if object.event?
        hasEvent = true
        timeline_list.push React.createElement(EventTile, object)

    if timeline_list.length
      timeline = [
        React.createElement("div", {key: "timeline-content"}, timeline_list)
      ]
    else
      # No events in the timeline, there are 3 cases. In archive,
      # or some are filtered, or none are filtered
      if @state.appType == 'archive'
        timeline = @getNoObjectsHeader "You have no archived thoughts for this "
      else if @state.appType == 'active'
        if @state.someFiltered
          timeline = @getNoObjectsHeader "You have filtered out all your thoughts for this "
        else
          timeline = @getNoObjectsHeader "You have not recorded any thoughts for this "

    app_nav_props = () =>
      key: "top_app_nav"
      top: true
      switchView: @switchView
      changeTimeRange: @changeTimeRange
      resetTimeRange: @resetTimeRange
      addEvent: @addEvent
      labels: @state.labels
      filterTokens: @filterTokens
      viewType: @state.view_type

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
    @props.switchView $(e.target.parentElement).data('view')

  goToPast: (e) ->
    @props.changeTimeRange true

  goToFuture: (e) ->
    @props.changeTimeRange false

  goToToday: (e) ->
    @props.resetTimeRange()

  componentDidMount: () ->
    @initializeFilterField()

  getNavigationButtons: () ->
    href = 'javascript:void(0)'
    className = 'navigation-button btn btn-default'
    textClassName = 'navigation-button text-navigation-button btn btn-default'
    past_options = {href, className, onClick: @goToPast}
    future_options = {href, className, onClick: @goToFuture}
    today_options = {href, className: textClassName, onClick: @goToToday}

    return [
      React.createElement("div", {key: 'today', className: "btn-group"},
        React.createElement("a", today_options,
          React.createElement("span", null, "Today")
        )
      )
      React.createElement("div", {key: 'past-future', className: "btn-group"},
        React.createElement("a", past_options,
          React.createElement(Icon, {icon: "navigation-chevron-left"})
        )
        React.createElement("a", future_options,
          React.createElement(Icon, {icon: "navigation-chevron-right"})
        )
      )
    ]

  getViewChangeButtons: () ->
    getButton = (type) =>
      React.createElement FlatButton, {
        className: 'navigation-button text-navigation-button'
        onClick: @switchView
        'data-view': type
        label: type.charAt(0).toUpperCase() + type.substr(1).toLowerCase()
        disabled: type == @props.viewType
        linkButton: true
      }

    React.createElement("div", {key: "view-button"},
      getButton("day")
      getButton("week")
      getButton("month")
      getButton("year")
    )

  getAddEventButton: () ->
    href = 'javascript:void(0)'
    React.createElement("div", {key: "add-event-button", className: "btn-group"},
      React.createElement(
        "a", {href, className: "btn btn-success small-btn", onClick: @props.addEvent}, 'Add Event')
    )

  getNewFilterTokens: (e) ->
    @props.filterTokens $("#label-filter").tokenfield('getTokensList')

  initializeFilterField: () ->
    getLabelList = () =>
      ({value: l} for l of @props.labels)

    engine = new Bloodhound({
      local: getLabelList()
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.value)
      queryTokenizer: Bloodhound.tokenizers.whitespace
    })
    engine.initialize()

    $("#label-filter").tokenfield({
      delay: 100
      delimiter: " "
      createTokensOnBlur: true
      typeahead: [null, {source: engine.ttAdapter()}]
    }).on('tokenfield:createtoken', (e) ->
      e.attrs.value = e.attrs.value.toLowerCase()
    ).on('tokenfield:createdtoken', @getNewFilterTokens
    ).on('tokenfield:removedtoken', @getNewFilterTokens)

  getLabelFilterField: () ->
    React.createElement("div", {key: "label-filter"},
      React.createElement("input", {
        type: "text", id: "label-filter", placeholder: "Filter by labels..."
      })
    )

  render: () ->
    navigation_buttons = @getNavigationButtons()
    filterField = @getLabelFilterField()
    left_side = [@getAddEventButton(), navigation_buttons]

    right_side = []
    if @props.top
      right_side = [@getViewChangeButtons()]

    allButtons = []
    if @props.top
      allButtons.push(
        React.createElement("div", {key: "ff-wrapper", className: "well well-sm filter-field-well"}
          filterField
        )
      )
    allButtons = allButtons.concat [
      React.createElement("div", {key: "left-right-wrapper", className: "well well-sm"},
        React.createElement("div", {key: "ls-buttons", className: "nav-buttons-left-side"}
          left_side
        )
        React.createElement("div", {key: "rs-buttons", className: "nav-buttons-right-side"},
          right_side
        )
      )
    ]

    # View changes
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8 app-navigation"},
      allButtons
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

  getEventExpandIcon: () ->
    if @props.eventShowAll
      return "navigation-expand-less"
    else
      return "navigation-expand-more"

  renderCollapsed: () ->
    return React.createElement("div", className: "event-header",
      React.createElement(Icon, {
        icon: "navigation-more-horiz", onClick: @handleExpand
      })
    )

  renderExpanded: (type) ->
    eventExpandIcon = @getEventExpandIcon()
    if type == 'active'
      buttons = [
        React.createElement(Icon, {
          key: "archive"
          icon: "content-archive", 'data-event_id': @props.eventId,
          onClick: @handleArchive
        })
        React.createElement(Icon, {
          key: "edit"
          icon: "content-create", 'data-event_id': @props.eventId,
          onClick: @handleBeginEdit
        })
      ]
    else if type == 'archived'
      buttons = [
        React.createElement(Icon, {
          key: "restore"
          icon: "content-reply", 'data-event_id': @props.eventId,
          onClick: @handleRestore
        })
        React.createElement(Icon, {
          key: "delete"
          icon: "content-clear", 'data-event_id': @props.eventId,
          onClick: @handleDelete
        })
      ]
    else
      throw Error "Unknown event type"

    buttons = buttons.concat [
      React.createElement(Icon,
        {key: "ee", icon: eventExpandIcon, onClick: @handleEventExpand})
      React.createElement(Icon, {key: "oe", icon: "navigation-more-horiz", onClick: @handleExpand})
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