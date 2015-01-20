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

  getLinkElement: (options) ->
    options['data-wysihtml5-command'] = options.command
    delete options.command
    mdiClass = options.s
    delete options.s
    options['data-wysihtml5-command-value'] = options.commandValue
    delete options.commandValue

    return React.createElement("a", options,
      React.createElement("span", className: mdiClass)
    )

  getToolbarComponent: () ->
    React.createElement("form", null,
      React.createElement("div", {id: "toolbar", style: {display: 'none'}}
        @getLinkElement {command: "bold", title: "ctrl+b", s: "mdi-editor-format-bold"}
        @getLinkElement {command: "italic", title: "ctrl+i", s: "mdi-editor-format-italic"}
        @getLinkElement {command: "underline", title: "ctrl+u", s: "mdi-editor-format-underline"}
      )
    )

  render: () ->
    React.createElement("div", id: "editor-container",
      @getToolbarComponent()
      React.createElement("div", {id: "editor", 'data-placeholder': "Enter text..."})
    )

module.exports = {Editor}
