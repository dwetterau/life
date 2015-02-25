React = require 'react'
{Icon, FlatButton, FontIcon} = require 'material-ui'

# Builds the necessary elements for the quill editor in React.js
# This file was generated from an existing jade file, excuse the mess
Editor = React.createClass
  displayName: 'Editor'

  getInitialState: (props) ->
    props = props || @props

    return {
      detail: props.detail
    }

  componentDidMount: () ->
    $editor = $('#editor')
    $editor.html @state.detail
    editor = new wysihtml5.Editor $editor.get(0),
      toolbar: $('#toolbar').get(0)
      parserRules: wysihtml5ParserRules
      pasteParserRulesets: wysihtml5ParserPasteRulesets

    editor.on "change", () =>
      @setState detail: $editor.html()

  getLinkElement: (options) ->
    options['data-wysihtml5-command'] = options.command
    delete options.command
    icon = options.s
    delete options.s

    if options.commandValue == ""
      options['data-wysihtml5-command-blank-value'] = "true"
    else
      options['data-wysihtml5-command-value'] = options.commandValue
    delete options.commandValue

    options.linkButton = true
    options.className = "ed-btn small-btn"
    if options.t?
      options.label = options.t
      return <FlatButton {...options}/>
    else
      options.label = ""
      return <FlatButton {...options}>
        <FontIcon className={"svg-ic_" + icon + "_24px icon-button"} />
      </FlatButton>

  getModal: (options) ->
    className = "well well-popup col-sm-4"
    React.createElement("div",
      {className, 'data-wysihtml5-dialog': options.action, style: {display: 'none'}},
      React.createElement("div", className: "form-group",
        React.createElement("label", className: "control-label", options.title)
        React.createElement("div", null,
          React.createElement("input", {
            'data-wysihtml5-dialog-field': options.field
            defaultValue: "http://"
            className: "form-control"
          })
        )
      )
      React.createElement("div", null,
        React.createElement("a",
          {'data-wysihtml5-dialog-action': "cancel", className: "btn btn-danger modal-submit-btn"},
          'Cancel'
        )
        React.createElement("a",
          {'data-wysihtml5-dialog-action': "save", className: "btn btn-success modal-submit-btn"},
          'Insert'
        )
      )
    )

  getToolbarComponent: () ->
    React.createElement("div", {id: "toolbar", style: {display: 'none'}}
      React.createElement("div", {className: "inline-block"},
        @getLinkElement {command: "formatBlock", commandValue: "h1", t: "Large"}
        @getLinkElement {command: "formatBlock", commandValue: "h3", t: "Medium"}
        @getLinkElement {command: "formatBlock", commandValue: "p", t: "Normal"}
        @getLinkElement {command: "formatBlock", commandValue: "", s: "format_clear"}
      )
      React.createElement("div", {className: "inline-block"},
        @getLinkElement {command: "bold", title: "ctrl+b", s: "format_bold"}
        @getLinkElement {command: "italic", title: "ctrl+i", s: "format_italic"}
        @getLinkElement {command: "underline", title: "ctrl+u", s: "format_underline"}
      )
      React.createElement("div", {className: "inline-block"},
        @getLinkElement {command: "insertUnorderedList", s: "format_list_bulleted"}
        @getLinkElement {command: "insertOrderedList", s: "format_list_numbered"}
      )
      React.createElement("div", {className: "inline-block"},
        @getLinkElement {command: "insertBlockQuote", s: "format_quote"}
        @getLinkElement {command: "createLink", s: "insert_link"}
        @getLinkElement {command: "insertImage", s: "insert_photo"}
      )
      @getModal {action: 'createLink', title: 'Link:', field: 'href'}
      @getModal {action: 'insertImage', title: 'Image:', field: 'src'}
    )

  render: () ->
    React.createElement("div", id: "editor-container",
      @getToolbarComponent()
      React.createElement("div", {id: "editor", 'data-placeholder': "Enter detail..."})
      React.createElement("input", {id: "detail", type: "hidden", value: @state.detail})
    )

module.exports = {Editor}
