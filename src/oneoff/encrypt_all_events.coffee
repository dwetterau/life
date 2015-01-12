{Event} = require '../models'
async = require 'async'

Event.findAll().then (events) ->
  for event in events
    console.log "Encrypting event id: " + event.id
    event.encrypt()

  saveEvent = (event, c) ->
    event.save().then((e) ->
      c null
    ).catch (err...) ->
      console.log err...
      c err

  functions = (((c) -> saveEvent(event, c)) for event in events)
  async.each events, ((e, c) -> saveEvent e, c), (err, results) ->
    if err
      return console.log "Error!", err
    console.log "Finished."
    process.exit()

.catch (err) ->
  console.log "There was an error"
  console.log err
