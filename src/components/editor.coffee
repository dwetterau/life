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

  getFontStylesTemplate: () ->
    return () ->
      return (
        '<li class="dropdown">
        <div class="btn-group">
        <a class="btn btn-default ed-btn small-btn">Font style</a>
        <a class="btn btn-default ed-btn small-btn dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
          <span class="current-font" style="display:none;"></span>
        </a>
        <ul class="dropdown-menu">
          <li>
          <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="p" tabindex="-1">
            <span>Normal text</span>
          </a></li>
          <li>
          <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h1" tabindex="-1">
            <span>Large header text</span>
          </a></li>
          <li>
          <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h2" tabindex="-1">
            <span>Medium header text</span>
          </a></li>
          <li>
          <a data-wysihtml5-command="formatBlock" data-wysihtml5-command-value="h3" tabindex="-1">
            <span>Small header text</span>
          </a></li>
        </ul>
        </div>
        </li>'
      )

  getEmphasisTemplate: () ->
    return () ->
      return (
        '<li><div class="btn-group">
        <a class="btn small-btn" data-wysihtml5-command="bold" title="ctrl+b" tabindex="-1">
          <span class="mdi-black mdi-editor-format-bold"></span>
        </a>
        <a class="btn small-btn" data-wysihtml5-command="italic" title="ctrl+i" tabindex="-1">
          <span class="mdi-black mdi-editor-format-italic"></span>
        </a>
        <a class="btn small-btn" data-wysihtml5-command="underline" title="ctrl+u" tabindex="-1">
          <span class="mdi-black mdi-editor-format-underline"></span>
        </a>
        </div></li>'
      )

  getListsTemplate: () ->
    return () ->
      return (
        '<li><div class="btn-group">
        <a class="btn btn-default ed-btn small-btn" data-wysihtml5-command="insertUnorderedList"
            title="Unordered list" tabindex="-1">
          <span class="mdi-black mdi-editor-format-list-bulleted"></span>
        </a>
        <a class="btn btn-default ed-btn small-btn" data-wysihtml5-command="insertOrderedList"
            title="Ordered list" tabindex="-1">
          <span class="mdi-black mdi-editor-format-list-numbered"></span>
        </a>
        </div></li>'
      )

  getLinkTemplate: () ->
    return () ->
      return (
        '<li>
        <div class="bootstrap-wysihtml5-insert-link-modal modal fade"
            data-wysihtml5-dialog="createLink">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h3>Insert link</h3>
              </div>
              <div class="modal-body">
                <div class="form-group">
                  <input value="http://" class="bootstrap-wysihtml5-insert-link-url form-control"
                      data-wysihtml5-dialog-field="href">
                </div>
              </div>
              <div class="form-group form-group-material-indigo text-right">
                <a href="#" class="btn btn-danger modal-submit-btn" data-dismiss="modal"
                    data-wysihtml5-dialog-action="cancel" href="#">Cancel</a>
                <a href="#" class="btn btn-success modal-submit-btn" data-dismiss="modal"
                    data-wysihtml5-dialog-action="save">Insert</a>
              </div>
            </div>
          </div>
        </div>
        <div class="btn-group">
          <a class="btn btn-default ed-btn small-btn" data-wysihtml5-command="createLink"
              title="Insert link" tabindex="-1">
            <span class="mdi-editor-insert-link"></span>
          </a>
        </div>
        </li>'
      )

  getImageTemplate: () ->
    return () ->
      return (
        '<li>
        <div class="bootstrap-wysihtml5-insert-image-modal modal fade"
            data-wysihtml5-dialog="insertImage">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <h3>Insert link</h3>
              </div>
              <div class="modal-body">
                <div class="form-group">
                  <input value="http://" class="bootstrap-wysihtml5-insert-image-url form-control"
                      data-wysihtml5-dialog-field="src">
                </div>
              </div>
              <div class="form-group form-group-material-indigo text-right">
                <a href="#" class="btn btn-danger modal-submit-btn" data-dismiss="modal"
                    data-wysihtml5-dialog-action="cancel" href="#">Cancel</a>
                <a href="#" class="btn btn-success modal-submit-btn" data-dismiss="modal"
                    data-wysihtml5-dialog-action="save">Insert</a>
              </div>
            </div>
          </div>
        </div>
        <div class="btn-group">
          <a class="btn btn-default ed-btn small-btn" data-wysihtml5-command="insertImage"
              title="Insert image" tabindex="-1">
            <span class="mdi-editor-insert-photo"></span>
          </a>
        </div>
        </li>'
      )

  componentDidMount: () ->
    $editor = $('#editor')
    $editor.wysihtml5 'deepExtend',
      toolbar:
        fa: false
        blockquote: false
        color: false
      customTemplates:
        emphasis: @getEmphasisTemplate()
        "font-styles": @getFontStylesTemplate()
        lists: @getListsTemplate()
        link: @getLinkTemplate()
        image: @getImageTemplate()
      classes:
        image: 1
        'image-row': 1
      tags:
        img:
          check_attributes:
            src: "src"

    $editor.data("wysihtml5").editor.composer.setValue @state.detail

  render: () ->
    return React.createElement("textarea", {id: "editor"})

module.exports = {Editor}
