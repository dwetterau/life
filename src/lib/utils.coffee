Utils =
  ###
  Calls Object.freeze on all keys recursively, instead of just freezing the top-level object.
  ###
  deepFreeze: (obj) ->
    for k, v of obj
      if typeof v == 'object'
        @.deepFreeze v
    Object.freeze obj

  hash: (s) ->
    hash = 0
    if s.length == 0
      return hash
    for i in [0...s.length]
      c = s.charCodeAt i
      hash = ((hash << 5) - hash) + c
      hash |= 0
    return hash

module.exports = Utils
