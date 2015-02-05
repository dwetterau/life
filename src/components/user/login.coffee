React = require 'react'
{FormPage} = require './form_page'

Login = React.createClass
  displayName: 'Login'
  render: () ->
    React.createElement FormPage,
      pageHeader: 'Sign in'
      action: '/user/login'
      inputs: [
        {
          type: "text"
          name: "username"
          key: "username"
          floatingLabelText: "Username"
          autofocus: ""
        }, {
          type: "password"
          name: "password"
          key: "password"
          floatingLabelText: "Password"
        }, {
          type: "hidden"
          name: "redirect"
          key: "redirect"
          value: @props.redirect
        }
      ]
      submitLabel: 'Login'

module.exports = {Login}
