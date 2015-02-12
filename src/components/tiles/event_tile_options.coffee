React = require 'react'
{Icon} = require 'material-ui'

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
    <div className="event-header">
      <Icon icon="navigation-more-horiz" onClick={@handleExpand} />
    </div>

  renderExpanded: (type) ->
    eventExpandIcon = @getEventExpandIcon()
    if type == 'active'
      buttons = [
        <Icon key="archive" icon="content-archive" data-event_id={@props.eventId} onClick={@handleArchive}/>
        <Icon key="edit" icon="content-create" data-event_id={@props.eventId} onClick={@handleBeginEdit}/>
      ]
    else if type == 'archived'
      buttons = [
        <Icon key="restore" icon="content-reply" data-event_id={@props.eventId} onClick={@handleRestore}/>
        <Icon key="delete" icon="content-clear" data-event_id={@props.eventId} onClick={@handleDelete}/>
      ]
    else
      throw Error "Unknown event type"

    buttons = buttons.concat [
      <Icon key="ee" icon={eventExpandIcon} onClick={@handleEventExpand}/>
      <Icon key="oe" icon="navigation-more-horiz" onClick={@handleExpand}/>
    ]

    <div key="buttons" className="event-header">
      {buttons}
    </div>

  render: () ->
    if not @state.optionsExpanded
      return @renderCollapsed()
    return @renderExpanded @props.type

module.exports = {EventTileOptions}
