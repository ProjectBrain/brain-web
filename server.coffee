http = require 'http'
url = require 'url'
express = require 'express'
zmq = require 'zmq'
WebSocketServer = require('ws').Server

app = express()

app.use express.static __dirname + '/public'

server = http.createServer app

proxies = {}

server.on 'upgrade', (request, socket, head) ->
  path = url.parse(request.url).pathname
  return unless wss = proxies[path]
  wss.handleUpgrade request, socket, head, (ws) ->
    wss.emit 'connection', ws


proxy = (sockname) ->
  zsock = zmq.socket 'sub'
  zsock.connect "ipc:///var/socks/#{sockname}"
  zsock.subscribe ''

  wss = new WebSocketServer noServer: true, clientTracking: true, perMessageDeflate: false
  proxies["/#{sockname}"] = wss
  broadcast = (data) ->
    wss.clients.forEach (ws) ->
      ws.send data, binary: false if ws.readyState is ws.OPEN

  zsock.on 'message', broadcast
  wss.on 'connection', (client) ->
    console.log 'connected', sockname
    client.on 'close', -> console.log 'disconnected', sockname

proxy 'quality'
proxy 'freqs'
proxy 'bands'
proxy 'bpmbands'
proxy 'fractal'
proxy 'entropy'

port = process.env.PORT or 8080
server.listen port
console.log "listening on #{port}"
