passport = require 'passport'

models = require '../models'

exports.get_user_create = (req, res) ->
  res.render 'user/create_account',
    title: 'Create Account'

exports.post_user_create = (req, res) ->
  req.assert('username', 'Username must be at least 3 characters long.').len(3)
  req.assert('password', 'Password must be at least 4 characters long.').len(4)
  req.assert('confirm_password', 'Passwords do not match.').equals(req.body.password)
  errors = req.validationErrors()

  if errors
    req.flash 'errors', errors
    return res.redirect '/user/create'

  username = req.body.username
  password = req.body.password
  new_user = models.User.build({username})
  new_user.hash_and_set_password password, (err) ->
    if err?
      req.flash 'errors', {msg: "Unable to create account at this time"}
      return res.redirect '/user/create'
    else
      new_user.save().then () ->
        req.logIn new_user, (err) ->
          req.flash 'success', {msg: 'Your account has been created!'}
          if err?
            req.flash 'info', {msg: "Could not automatically log you in at this time."}
          res.redirect '/'
      .catch () ->
        req.flash 'errors', {msg: 'Username already in use!'}
        res.redirect '/user/create'

exports.get_user_login = (req, res) ->
  redirect = req.param('r')
  res.render 'user/login', {
    title: 'Login'
    props: JSON.stringify {redirect}
  }

exports.post_user_login = (req, res, next) ->
  req.assert('username', 'Username is not valid.').notEmpty()
  req.assert('password', 'Password cannot be blank.').notEmpty()
  redirect = req.param('redirect')
  redirect_string = if redirect then '?r=' + encodeURIComponent(redirect) else ''
  redirect_url = decodeURIComponent(redirect)

  errors = req.validationErrors()
  if errors?
    req.flash 'errors', errors
    return res.redirect '/user/login' + redirect_string

  passport.authenticate('local', (err, user, info) ->
    if err?
      return next(err)
    if not user
      req.flash 'errors', {msg: info.message}
      return res.redirect '/user/login' + redirect_string
    req.logIn user, (err) ->
      if err?
        return next err

      req.flash 'success', {msg: "Login successful!"}
      res.redirect redirect_url || '/'
  )(req, res, next)

exports.get_user_logout = (req, res) ->
  req.logout()
  res.redirect '/'

exports.post_change_password = (req, res) ->
  req.assert('old_password', 'Password must be at least 4 characters long.').len(4)
  req.assert('new_password', 'Password must be at least 4 characters long.').len(4)
  req.assert('confirm_password', 'Passwords do not match.').equals(req.body.new_password)
  errors = req.validationErrors()

  if errors
    req.flash 'errors', errors
    return res.redirect '/user/password'

  old_password = req.body.old_password
  new_password = req.body.new_password

  fail = () ->
    req.flash 'errors', {msg: 'Failed to update password.'}
    return res.redirect '/user/password'

  models.User.findById(req.user.id).then (user) ->
    user.compare_password old_password, (err, is_match) ->
      if not is_match or err
        req.flash 'errors', {msg: 'Current password incorrect.'}
        return fail()

      user.hash_and_set_password new_password, (err) ->
        if err?
          return fail()
        user.save().then () ->
          req.flash 'success', {msg: 'Password changed!'}
          res.redirect '/user/password'
        .catch fail
  .catch fail

exports.get_change_password = (req, res) ->
  res.render 'user/change_password', {
    user: req.user,
    title: 'Change Password'
  }
