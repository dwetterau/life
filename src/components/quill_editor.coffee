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
    # Initialize the editor
    editor = new Quill '#editor', {
      modules:
        'toolbar': {container: '#toolbar'}
        'link-tooltip': true
        'image-tooltip': true
      theme: 'snow'
    }
    editor.setHTML(@state.detail)
    editor.on 'text-change', () =>
      @setState({detail: editor.getHTML()})

    $('#toolbar').show()

    $('#editor').click () ->
      $('.ql-editor').get(0).focus()

  render: () ->
    tags = []
    tags.push React.createElement("div",
      id: "toolbar"
      style:
        display: "none"
      className: "editor ql-toolbar ql-snow"
    , React.createElement("span",
        className: "ql-format-group"
      React.createElement("select",
          title: "Size"
          defaultValue: "13px"
          className: "ql-size"
        , React.createElement("option",
            value: "10px"
          , "Small")
        , React.createElement("option",
            value: "13px"
          , "Normal")
        , React.createElement("option",
            value: "18px"
          , "Large")
        , React.createElement("option",
            value: "32px"
          , "Huge")))
    , React.createElement("span",
        className: "ql-format-group"
      , React.createElement("span",
          title: "Bold"
          className: "ql-format-button ql-bold"
        )
      , React.createElement("span",
          className: "ql-format-separator"
        )
      , React.createElement("span",
          title: "Italic"
          className: "ql-format-button ql-italic"
        )
      , React.createElement("span",
          className: "ql-format-separator"
        )
      , React.createElement("span",
          title: "Underline"
          className: "ql-format-button ql-underline"
        )
      , React.createElement("span",
          className: "ql-format-separator"
        )
      , React.createElement("span",
          title: "Strikethrough"
          className: "ql-format-button ql-strike"
        ))
    , React.createElement("span",
        className: "ql-format-group"
      , React.createElement("span",
          title: "List"
          className: "ql-format-button ql-list"
        )
      , React.createElement("span",
          className: "ql-format-separator"
        )
      , React.createElement("span",
          title: "Bullet"
          className: "ql-format-button ql-bullet"
        )
      , React.createElement("span",
          className: "ql-format-separator"
        )
      , React.createElement("select",
          title: "Text Alignment"
          defaultValue: "left"
          className: "ql-align"
        , React.createElement("option",
            value: "left"
            label: "Left"
          )
        , React.createElement("option",
            value: "center"
            label: "Center"
          )
        , React.createElement("option",
            value: "right"
            label: "Right"
          )
        , React.createElement("option",
            value: "justify"
            label: "Justify"
          )))
    , React.createElement("span",
        className: "ql-format-group"
      , React.createElement("span",
          title: "Link"
          className: "ql-format-button ql-link"
        )
      , React.createElement("span",
          className: "ql-format-separator"
        )
      , React.createElement("span",
          title: "Image"
          className: "ql-format-button ql-image"
        )))
    editor = {id: "editor", className: "editor ql-container ql-snow"}
    tags.push React.createElement("div", editor)
    tags.push React.createElement("input", {
      id: "detail", name: "detail", type: "hidden", value: @state.detail})
    tags.unshift "div", null
    return React.createElement.apply React, tags

module.exports = {Editor}
