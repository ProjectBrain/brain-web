http = require 'http'
express = require 'express'
zmq = require 'zmq'
WebSocketServer = require('ws').Server

app = express()

#app.use require('coffee-middleware')({src: __dirname})
app.use express.static __dirname+'/public'

server = http.createServer app

proxy = (sockname) ->
  zsock = zmq.socket 'sub'
  zsock.connect "ipc:///var/socks/#{sockname}"
  zsock.subscribe ''

  wss = new WebSocketServer {server: server, path: "/#{sockname}"}
  broadcast = (data) ->
    # console.log 'data', data
    #console.log 'broadcasting', sockname
    ws.send data, binary: false for ws in wss.clients when ws.readyState is ws.OPEN
  zsock.on 'message', broadcast
  wss.on 'connection', (client) ->
    console.log 'connected', sockname
    client.on 'close', -> console.log 'disconnected', sockname

proxy 'quality'
proxy 'freqs'
proxy 'bands'
proxy 'fractal'

server.listen 8080
console.log 'listening on 8080'
