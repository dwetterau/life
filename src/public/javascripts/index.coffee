# Client-side stuff here
# Initialize the material effects
$.material.init()

if $('form#add_event').length

  # Initialize the time/date picker
  #$('input#date').datetimepicker()

  # Initialize the editor
  editor = new Quill '#editor', {
    modules:
      'toolbar': {container: '#toolbar'}
      'link-tooltip': true
      'image-tooltip': true
    theme: 'snow'
  }
  $('#toolbar').show()
  $('#editor').click () ->
    $('.ql-editor').get(0).focus()
