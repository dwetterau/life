React = require 'react'
{Paper} = require 'material-ui'
{EventTileOptions} = require './event_tile_options'
{EditEvent} = require '../edit_event'

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

      <Paper className="default-paper event-paper">
        <div className="event-container">
          <div key="date" className="event-date">
            {@state.to_display.date}
            <EventTileOptions {...tileOptions}/>
          </div>
          <div className="event-detail" key="detail"
            dangerouslySetInnerHTML={__html: @state.to_display.detail}>
          </div>
        </div>
      </Paper>

module.exports = {EventTile}
