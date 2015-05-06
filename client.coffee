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
    #console.log "msg", msg
    data.raw = msg.raw if msg.raw
    data.quality = msg.quality if msg.quality
    if msg.processed
      data.processed = msg.processed
      drawGraph()
    if msg.bands
      data.bands = msg.bands
      drawBands()
  
setInterval ->
  console.log "raw", data.raw
  console.log "quality", data.quality
  console.log "processed", data.processed
  console.log "bands", data.bands
, 1000


pt = (x, y) -> {x, y}

LOCATIONS =
  AF3: pt 160, 111
  AF4: pt 227, 110  
  F7: pt 88, 121
  F8: pt 299, 121
  F3: pt 139, 151
  F4: pt 246, 151
  FC5: pt 98, 173
  FC6: pt 289, 172
  T7: pt 58, 204
  T8: pt 330, 206
  P7: pt 83, 280
  P8: pt 304, 280
  O1: pt 139, 331
  O2: pt 247, 331

LOCATIONS_A = Object.keys(LOCATIONS)

do ->
  canvas = $('#quality')
  ctx = canvas.getContext '2d'
  canvas.addEventListener 'click', (e) ->
    console.log "e", e.layerX, e.layerY
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.fillStyle = "black"
    ctx.textAlign = "left"
    ctx.beginPath()
    ctx.arc(e.layerX, e.layerY, 20, 0, Math.PI*2)
    ctx.closePath()
    ctx.fill()
    ctx.fillText("#{e.layerX},#{e.layerY}", e.layerX+30, e.layerY)

  setInterval ->
    ctx.textAlign = "center"
    ctx.textBaseline = "middle"
    QUALITY_MAX = 5
    for sensor, loc of LOCATIONS
      ctx.beginPath()
      ctx.arc(loc.x, loc.y, 20, 0, Math.PI*2)
      ctx.closePath()
      greenness = Math.min(data.quality[sensor]/QUALITY_MAX,1)
      ctx.fillStyle = "rgb(#{Math.round((1-greenness)*255)},#{Math.round(greenness*255)},0)"
      ctx.fill()
      ctx.fillStyle = "black"
      ctx.fillText(sensor, loc.x, loc.y-8)
      ctx.fillText(data.raw[sensor], loc.x, loc.y+8) if data.raw
  , 1000

drawGraph = null
do ->
  canvas = $('#graph')
  ctx = canvas.getContext '2d'
  line = (x1, y1, x2, y2, color) ->
    #console.log("x1", x1, "y1", y1, "x2", x2, "y2", y2, "color", color) if x1 == 0
    ctx.strokeStyle = color
    ctx.beginPath()
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)
    ctx.stroke()

  bottom = canvas.height

  drawGraph = ->
    return if drawing
    drawing = true
    requestAnimationFrame ->
      drawing = false
      return unless data.processed
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      ctx.textAlign = 'left'
      margin = 16
      xscale = canvas.width/data.processed.freq.length
      xscale *= 4
      for powers, i in data.processed.psd.slice(0,xscale)
        continue if data.quality and data.quality[LOCATIONS_A[i]] < 5
        hue = Math.round(i/data.processed.psd.length*255)
        ctx.strokeStyle = "hsl(#{hue}, 50%, 75%)"
        ctx.fillStyle = "hsl(#{hue}, 50%, 75%)"
        ctx.fillText LOCATIONS_A[i], 0, i/LOCATIONS_A.length*canvas.height
        ctx.beginPath()
        for y, x in powers
          #y = y / 100
          #y = Math.log(y)*10
          if x == 0
            ctx.moveTo(x+margin, bottom-y-margin)
          else
            ctx.lineTo(x*xscale+margin, bottom-y-margin)
        ctx.stroke()
      ctx.textAlign = 'center'
      ctx.fillStyle = 'black'
      for freq, x in data.processed.freq
        ctx.fillText freq, x*xscale, bottom if freq % 1 == 0

drawBands = null
do ->
  canvas = $('#bands')
  ctx = canvas.getContext '2d'

  bottom = canvas.height

  drawBands = ->
    return if drawing
    drawing = true
    requestAnimationFrame ->
      drawing = false
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      ctx.textAlign = 'left'
      i = 0
      width = 32
      for band, powers of data.bands
        for power, sensor in powers
          hue = Math.round(sensor/powers.length*255)
          scaledpower = power / data.bands.global[sensor]
          #console.log 'sensor', sensor, 'global', data.bands.global[sensor]
          ctx.fillStyle = "hsla(#{hue}, 50%, 75%, 0.2)"
          ctx.fillRect((i*width)+16, canvas.height-16, width, -scaledpower*100)
        ctx.fillStyle = 'black'
        ctx.fillText("#{band}", (i*width)+16, canvas.height-16)
        i++
      return unless data.processed

connect()
