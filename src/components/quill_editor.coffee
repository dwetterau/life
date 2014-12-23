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
      , React.createElement("select",
          title: "Font"
          defaultValue: "sans-serif"
          className: "ql-font"
        , React.createElement("option",
            value: "sans-serif"
          , "Sans Serif")
        , React.createElement("option",
            value: "serif"
          , "Serif")
        , React.createElement("option",
            value: "monospace"
          , "Monospace"))
      , React.createElement("select",
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
      , React.createElement("select",
          title: "Text Color"
          defaultValue: "rgb(0, 0, 0)"
          className: "ql-color"
        , React.createElement("option",
            value: "rgb(0, 0, 0)"
            label: "rgb(0, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(230, 0, 0)"
            label: "rgb(230, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(255, 153, 0)"
            label: "rgb(255, 153, 0)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 0)"
            label: "rgb(255, 255, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 138, 0)"
            label: "rgb(0, 138, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 102, 204)"
            label: "rgb(0, 102, 204)"
          )
        , React.createElement("option",
            value: "rgb(153, 51, 255)"
            label: "rgb(153, 51, 255)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 255)"
            label: "rgb(255, 255, 255)"
          )
        , React.createElement("option",
            value: "rgb(250, 204, 204)"
            label: "rgb(250, 204, 204)"
          )
        , React.createElement("option",
            value: "rgb(255, 235, 204)"
            label: "rgb(255, 235, 204)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 204)"
            label: "rgb(255, 255, 204)"
          )
        , React.createElement("option",
            value: "rgb(204, 232, 204)"
            label: "rgb(204, 232, 204)"
          )
        , React.createElement("option",
            value: "rgb(204, 224, 245)"
            label: "rgb(204, 224, 245)"
          )
        , React.createElement("option",
            value: "rgb(235, 214, 255)"
            label: "rgb(235, 214, 255)"
          )
        , React.createElement("option",
            value: "rgb(187, 187, 187)"
            label: "rgb(187, 187, 187)"
          )
        , React.createElement("option",
            value: "rgb(240, 102, 102)"
            label: "rgb(240, 102, 102)"
          )
        , React.createElement("option",
            value: "rgb(255, 194, 102)"
            label: "rgb(255, 194, 102)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 102)"
            label: "rgb(255, 255, 102)"
          )
        , React.createElement("option",
            value: "rgb(102, 185, 102)"
            label: "rgb(102, 185, 102)"
          )
        , React.createElement("option",
            value: "rgb(102, 163, 224)"
            label: "rgb(102, 163, 224)"
          )
        , React.createElement("option",
            value: "rgb(194, 133, 255)"
            label: "rgb(194, 133, 255)"
          )
        , React.createElement("option",
            value: "rgb(136, 136, 136)"
            label: "rgb(136, 136, 136)"
          )
        , React.createElement("option",
            value: "rgb(161, 0, 0)"
            label: "rgb(161, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(178, 107, 0)"
            label: "rgb(178, 107, 0)"
          )
        , React.createElement("option",
            value: "rgb(178, 178, 0)"
            label: "rgb(178, 178, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 97, 0)"
            label: "rgb(0, 97, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 71, 178)"
            label: "rgb(0, 71, 178)"
          )
        , React.createElement("option",
            value: "rgb(107, 36, 178)"
            label: "rgb(107, 36, 178)"
          )
        , React.createElement("option",
            value: "rgb(68, 68, 68)"
            label: "rgb(68, 68, 68)"
          )
        , React.createElement("option",
            value: "rgb(92, 0, 0)"
            label: "rgb(92, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(102, 61, 0)"
            label: "rgb(102, 61, 0)"
          )
        , React.createElement("option",
            value: "rgb(102, 102, 0)"
            label: "rgb(102, 102, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 55, 0)"
            label: "rgb(0, 55, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 41, 102)"
            label: "rgb(0, 41, 102)"
          )
        , React.createElement("option",
            value: "rgb(61, 20, 102)"
            label: "rgb(61, 20, 102)"
          ))
      , React.createElement("span",
          className: "ql-format-separator"
        ), React.createElement("select",
          title: "Background Color"
          defaultValue: "rgb(255, 255, 255)"
          className: "ql-background"
        , React.createElement("option",
            value: "rgb(0, 0, 0)"
            label: "rgb(0, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(230, 0, 0)"
            label: "rgb(230, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(255, 153, 0)"
            label: "rgb(255, 153, 0)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 0)"
            label: "rgb(255, 255, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 138, 0)"
            label: "rgb(0, 138, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 102, 204)"
            label: "rgb(0, 102, 204)"
          )
        , React.createElement("option",
            value: "rgb(153, 51, 255)"
            label: "rgb(153, 51, 255)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 255)"
            label: "rgb(255, 255, 255)"
          )
        , React.createElement("option",
            value: "rgb(250, 204, 204)"
            label: "rgb(250, 204, 204)"
          )
        , React.createElement("option",
            value: "rgb(255, 235, 204)"
            label: "rgb(255, 235, 204)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 204)"
            label: "rgb(255, 255, 204)"
          )
        , React.createElement("option",
            value: "rgb(204, 232, 204)"
            label: "rgb(204, 232, 204)"
          )
        , React.createElement("option",
            value: "rgb(204, 224, 245)"
            label: "rgb(204, 224, 245)"
          )
        , React.createElement("option",
            value: "rgb(235, 214, 255)"
            label: "rgb(235, 214, 255)"
          )
        , React.createElement("option",
            value: "rgb(187, 187, 187)"
            label: "rgb(187, 187, 187)"
          )
        , React.createElement("option",
            value: "rgb(240, 102, 102)"
            label: "rgb(240, 102, 102)"
          )
        , React.createElement("option",
            value: "rgb(255, 194, 102)"
            label: "rgb(255, 194, 102)"
          )
        , React.createElement("option",
            value: "rgb(255, 255, 102)"
            label: "rgb(255, 255, 102)"
          )
        , React.createElement("option",
            value: "rgb(102, 185, 102)"
            label: "rgb(102, 185, 102)"
          )
        , React.createElement("option",
            value: "rgb(102, 163, 224)"
            label: "rgb(102, 163, 224)"
          )
        , React.createElement("option",
            value: "rgb(194, 133, 255)"
            label: "rgb(194, 133, 255)"
          )
        , React.createElement("option",
            value: "rgb(136, 136, 136)"
            label: "rgb(136, 136, 136)"
          )
        , React.createElement("option",
            value: "rgb(161, 0, 0)"
            label: "rgb(161, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(178, 107, 0)"
            label: "rgb(178, 107, 0)"
          )
        , React.createElement("option",
            value: "rgb(178, 178, 0)"
            label: "rgb(178, 178, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 97, 0)"
            label: "rgb(0, 97, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 71, 178)"
            label: "rgb(0, 71, 178)"
          )
        , React.createElement("option",
            value: "rgb(107, 36, 178)"
            label: "rgb(107, 36, 178)"
          )
        , React.createElement("option",
            value: "rgb(68, 68, 68)"
            label: "rgb(68, 68, 68)"
          )
        , React.createElement("option",
            value: "rgb(92, 0, 0)"
            label: "rgb(92, 0, 0)"
          )
        , React.createElement("option",
            value: "rgb(102, 61, 0)"
            label: "rgb(102, 61, 0)"
          )
        , React.createElement("option",
            value: "rgb(102, 102, 0)"
            label: "rgb(102, 102, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 55, 0)"
            label: "rgb(0, 55, 0)"
          )
        , React.createElement("option",
            value: "rgb(0, 41, 102)"
            label: "rgb(0, 41, 102)"
          )
        , React.createElement("option",
            value: "rgb(61, 20, 102)"
            label: "rgb(61, 20, 102)"
          )))
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
    tags.push React.createElement("div",
      id: "editor"
      className: "editor ql-container ql-snow"
    )
    tags.push React.createElement("input", {
      id: "detail", name: "detail", type: "hidden", value: @state.detail})
    tags.unshift "div", null
    return React.createElement.apply React, tags

module.exports = {Editor}
