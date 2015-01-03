exports.get_home_logged_out = (req, res) ->
  res.send {status: 'ok', logged_in: "false"}

exports.get_home_logged_in = (req, res) ->
  res.send {status: 'ok', logged_in: "true"}