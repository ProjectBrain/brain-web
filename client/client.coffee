require './style.css'

riot = require 'riot'
require './components/brainweb-bands.tag'
require './components/brainweb-quality.tag'
require './components/brainweb-freqs.tag'

[bands] = riot.mount 'brainweb-bands'
[quality] = riot.mount 'brainweb-quality'
[freqs] = riot.mount 'brainweb-freqs'

#[bands, quality, freqs] = riot.mount 'brainweb-bands,brainweb-quality,brainweb-freqs'

window.bands = bands
window.quality = quality
window.riot = riot

$ = document.querySelector.bind(document)
data = {}

window.data = data

connect = ->
  protocol = if window.location.protocol is "https:" then "wss" else "ws"
  ws = new WebSocket "#{protocol}://#{window.location.host}/ws/"

  ws.onopen = ->
    console.log 'connected'

  ws.onclose = ->
    console.log 'disconnected'
    setTimeout ->
      connect()
    , 2000

  ws.onmessage = (_data) ->
    msg = JSON.parse _data.data

    if msg.bands
      bands.bands = msg.bands
      bands.update()

    if msg.quality
      quality.quality = msg.quality
      quality.update()

    if msg.freqs
      freqs.freqs = msg.freqs
      freqs.update()

connect()