React = require 'react'
{FormPage} = require './form_page'

CreateUser = React.createClass
  displayName: 'CreateUser'
  render: () ->
    React.createElement FormPage,
      pageHeader: 'Create an account'
      action: '/user/create'
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
          type: "password"
          name: "confirm_password"
          key: "confirm_password"
          floatingLabelText: "Confirm Password"
        }
      ]
      submitLabel: 'Create account'

module.exports = {CreateUser}
