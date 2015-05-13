http = require 'http'
express = require 'express'
zmq = require 'zmq'
WebSocketServer = require('ws').Server

#raw = zmq.socket 'sub'
#raw.connect 'ipc:///var/socks/raw'
#raw.subscribe ''

quality = zmq.socket 'sub'
quality.connect 'ipc:///var/socks/quality'
quality.subscribe ''

freqs = zmq.socket 'sub'
freqs.connect 'ipc:///var/socks/freqs'
freqs.subscribe ''

bands = zmq.socket 'sub'
bands.connect 'ipc:///var/socks/bands'
bands.subscribe ''

app = express()

#app.use require('coffee-middleware')({src: __dirname})
app.use express.static __dirname+'/public'

server = http.createServer app

wss = new WebSocketServer {server: server}

sockets = []
broadcast = (msg) ->
  ws.send JSON.stringify msg for ws in sockets when ws.readyState is ws.OPEN

broadcastRaw = (msg) ->
  ws.send msg for ws in sockets when ws.readyState is ws.OPEN

#raw.on 'message', (message) ->
#  message = JSON.parse(message)
#  broadcast raw: message

#quality.on 'message', (message) ->
#  message = JSON.parse(message)
#  broadcast quality: message

quality.on 'message', (message) ->
  broadcastRaw '{"quality":' + message + '}'

freqs.on 'message', (message) ->
  broadcastRaw '{"freqs":' + message + '}'

bands.on 'message', (message) ->
  broadcastRaw '{"bands":' + message + '}'

wss.on 'connection', (ws) ->
  sockets.push ws
  ws.on 'close', (ws) ->
    sockIndex = sockets.indexOf(ws)
    sockets.splice(sockIndex, 1) if sockIndex > -1

server.listen 8080
console.log 'listening on 8080'
