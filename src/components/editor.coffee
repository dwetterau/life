React = require 'react'

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
    mdiClass = options.s
    delete options.s

    if options.commandValue is ""
      options['data-wysihtml5-command-blank-value'] = "true"
    else
      options['data-wysihtml5-command-value'] = options.commandValue
    delete options.commandValue

    return React.createElement("a", options, options.t
      React.createElement("span", className: mdiClass)
    )

  getModal: (options) ->
    React.createElement("div"
      {'data-wysihtml5-dialog': options.action, style: {display: 'none'}},
      React.createElement("label", null, options.title,
        React.createElement("input",
          {'data-wysihtml5-dialog-field': options.field, defaultValue: "http://"})
      )
      React.createElement("div", null,
        React.createElement("a", {'data-wysihtml5-dialog-action': "cancel"}, 'Cancel')
        React.createElement("a", {'data-wysihtml5-dialog-action': "save"}, 'Insert')
      )
    )

  getToolbarComponent: () ->
    React.createElement("div", {id: "toolbar", style: {display: 'none'}}
      @getLinkElement {command: "formatBlock", commandValue: "h1", t: "Large"}
      @getLinkElement {command: "formatBlock", commandValue: "h3", t: "Medium"}
      @getLinkElement {command: "formatBlock", commandValue: "p", t: "Normal"}
      @getLinkElement {command: "formatBlock", commandValue: "", s: "mdi-editor-fomat-clear"}
      @getLinkElement {command: "bold", title: "ctrl+b", s: "mdi-editor-format-bold"}
      @getLinkElement {command: "italic", title: "ctrl+i", s: "mdi-editor-format-italic"}
      @getLinkElement {command: "underline", title: "ctrl+u", s: "mdi-editor-format-underline"}
      @getLinkElement {command: "insertUnorderedList", s: "mdi-editor-format-list-bulleted"}
      @getLinkElement {command: "insertOrderedList", s: "mdi-editor-format-list-numbered"}
      @getLinkElement {command: "insertBlockQuote", s: "mdi-editor-format-quote"}
      @getLinkElement {command: "createLink", s: "mdi-editor-insert-link"}
      @getLinkElement {command: "insertImage", s: "mdi-editor-insert-photo"}

      @getModal {action: 'createLink', title: 'Link:', field: 'href'}
      @getModal {action: 'insertImage', title: 'Image:', field: 'src'}
    )

  render: () ->
    React.createElement("div", id: "editor-container",
      @getToolbarComponent()
      React.createElement("div", {id: "editor", 'data-placeholder': "Enter text..."})
      React.createElement("input", {id: "detail", type: "hidden", value: @state.detail})
    )

module.exports = {Editor}
