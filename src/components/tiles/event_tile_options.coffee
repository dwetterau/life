React = require 'react'
{FontIcon} = require 'material-ui'

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
      return "svg-ic_expand_less_24px icon-button"
    else
      return "svg-ic_expand_more_24px icon-button"

  renderCollapsed: () ->
    <div className="event-header">
      <FontIcon className="svg-ic_more_horiz_24px icon-button" onClick={@handleExpand} />
    </div>

  renderExpanded: (type) ->
    eventExpandIcon = @getEventExpandIcon()
    if type == 'active'
      buttons = [
        <FontIcon key="archive" className="svg-ic_archive_24px icon-button" data-event_id={@props.eventId} onClick={@handleArchive}/>
        <FontIcon key="edit" className="svg-ic_create_24px icon-button" data-event_id={@props.eventId} onClick={@handleBeginEdit}/>
      ]
    else if type == 'archived'
      buttons = [
        <FontIcon key="restore" className="svg-ic_reply_24px icon-button" data-event_id={@props.eventId} onClick={@handleRestore}/>
        <FontIcon key="delete" className="svg-ic_clear_24px icon-button" data-event_id={@props.eventId} onClick={@handleDelete}/>
      ]
    else
      throw Error "Unknown event type"

    buttons = buttons.concat [
      <FontIcon key="ee" className={eventExpandIcon} onClick={@handleEventExpand}/>
      <FontIcon key="oe" className="svg-ic_more_horiz_24px icon-button" onClick={@handleExpand}/>
    ]

    <div key="buttons" className="event-header">
      {buttons}
    </div>

  render: () ->
    if not @state.optionsExpanded
      return @renderCollapsed()
    return @renderExpanded @props.type

module.exports = {EventTileOptions}
