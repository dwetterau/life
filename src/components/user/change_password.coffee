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
          id: "old_password"
          floatingLabelText: "Old Password"
          autofocus: true
        }, {
          type: "password"
          name: "new_password"
          key: "new_password"
          id: "new_password"
          floatingLabelText: "New Password"
        }, {
          type: "password"
          name: "confirm_password"
          key: "confirm_password"
          id: "confirm_password"
          floatingLabelText: "Confirm Password"
        }
      ]
      submitLabel: 'Change password'

module.exports = {ChangePassword}
