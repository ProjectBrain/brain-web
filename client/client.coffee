require './style.css'

riot = require 'riot'
require './components/brainweb-bands.tag'
require './components/brainweb-quality.tag'
require './components/brainweb-freqs.tag'
require './components/brainweb-localised.tag'
require './components/brainweb-audio.tag'

[bands] = riot.mount 'brainweb-bands'
[quality] = riot.mount 'brainweb-quality'
[freqs] = riot.mount 'brainweb-freqs'
[localised] = riot.mount 'brainweb-localised'
[audio] = riot.mount 'brainweb-audio'

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

    if bands and msg.bands
      bands.bands = msg.bands
      bands.update()

    if localised and msg.bands
      localised.bands = msg.bands
      localised.update()

    if quality and msg.quality
      quality.quality = msg.quality
      quality.update()

    if freqs and msg.freqs
      freqs.freqs = msg.freqs
      freqs.update()

    if audio and msg.freqs
      audio.freqs = msg.freqs
      audio.update()

connect()