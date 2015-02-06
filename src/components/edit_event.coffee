React = require 'react'
moment = require 'moment'
{Selector} = require './time_selector'
{Editor} = require './editor'
{Paper} = require 'material-ui'

EditEvent = React.createClass
  displayName: 'EditEvent'

  getInitialState: (props) ->
    props = props || @props

    action = if props.event.id? then '/event/update' else '/event/add'

    return {
      event: props.event
      action
    }

  componentWillReceiveProps: (new_props, old_props) ->
    @setState @getInitialState(new_props)

  getLabelList: () ->
    ({value: l} for l of @props.labels)

  componentDidMount: () ->
    engine = new Bloodhound({
      local: @getLabelList()
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.value)
      queryTokenizer: Bloodhound.tokenizers.whitespace
    })
    engine.initialize()
    $("input#labels").tokenfield({
      delay: 100
      delimiter: " "
      createTokensOnBlur: true
      typeahead: [null, {source: engine.ttAdapter()}]
    }).on 'tokenfield:createtoken', (e) ->
      e.attrs.value = e.attrs.value.toLowerCase()

  convertToString: (array) ->
    if not array?
      return ""
    array.sort()
    return array.join(" ")

  handleSubmit: () ->
    @props.submit_handler @state.event, @state.action

  render: () ->
    <Paper className="default-paper">
      <div className="form-container">
        <form id="event_form">
          <div className="form-group">
            <Selector  date={@state.event.date} />
          </div>
          <div className="form-group">
            <Editor detail={@state.event.detail} />
          </div>
        </form>

        <div className="form-group">
          <input type="text" name="labels" id="labels" placeholder="Enter labels..."
            defaultValue={@convertToString(@state.event.labels)} />
        </div>

        <div className="form-group button-row text-right">
          <button className="btn btn-danger submit-button" onClick={@props.cancel_handler}>
            <span>Cancel</span>
          </button>
          <button className="btn btn-success submit-button" onClick={@handleSubmit}>
            <span>Done</span>
          </button>
        </div>
      </div>
    </Paper>

module.exports = {EditEvent}
