require './style.css'

riot = require 'riot'
require './components/brainweb-bands.tag'
require './components/brainweb-quality.tag'
require './components/brainweb-freqs.tag'
require './components/brainweb-localised.tag'
require './components/brainweb-audio.tag'
require './components/brainweb-fractal.tag'
require './components/brainweb-entropy.tag'
require './components/brainweb-entropy-logger.tag'

protocol = if window.location.protocol is 'https:' then 'wss' else 'ws'
receivers = {}
receive = (sockname, cb) ->
  if !receivers[sockname]
    receiver = receivers[sockname] = {listeners: []}
    connect = ->
      ws = receiver.ws = new WebSocket "#{protocol}://#{window.location.host}/#{sockname}"
      console.log 'connecting', sockname
      ws.onopen = ->
        console.log 'connected', sockname

      ws.onclose = ->
        console.log 'disconnected', sockname
        setTimeout ->
          connect()
        , 2000

      ws.onmessage = (msg) ->
        # console.log 'msg', msg
        data = JSON.parse(msg.data)
        listener(data) for listener in receiver.listeners

    connect()

  receivers[sockname].listeners.push cb

window.receive = receive

riot.mount '*'

window.riot = riot

$ = document.querySelector.bind(document)
