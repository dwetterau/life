React = require 'react'
{FormPage} = require './form_page'

Login = React.createClass
  displayName: 'Login'
  render: () ->
    React.createElement FormPage,
      pageHeader: 'Create an account'
      action: '/user/login'
      inputs: [
        {
          type: "text"
          name: "username"
          key: "username"
          placeholder: "Username"
          autofocus: ""
        }, {
          type: "password"
          name: "password"
          key: "password"
          placeholder: "Password"
        }, {
          type: "hidden"
          name: "redirect"
          key: "redirect"
          value: @props.redirect
        }
      ]
      submitLabel: 'Login'

module.exports = {Login}
