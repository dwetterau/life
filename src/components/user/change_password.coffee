React = require 'react'
{FormPage} = require './form_page'

ChangePassword = React.createClass
  displayName: 'ChangePassword'
  render: () ->
    React.createElement FormPage,
      pageHeader: 'Change Password'
      action: '/user/password'
      inputs: [
        {
          type: "password"
          name: "old_password"
          key: "old_password"
          placeholder: "Old Password"
          autofocus: ""
        }, {
          type: "password"
          name: "new_password"
          key: "new_password"
          placeholder: "New Password"
        }, {
          type: "password"
          name: "confirm_password"
          key: "confirm_password"
          placeholder: "Confirm Password"
        }
      ]
      submitLabel: 'Change password'

module.exports = {ChangePassword}
