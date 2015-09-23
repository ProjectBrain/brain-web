riot = require('riot')

<brainweb-quality>

  <canvas name="canvas" width={ opts.width } height={ opts.height }></canvas>

  <style scoped>
    :scope {
      display: block;
      /*flex: 0 1 auto;*/
    }
    canvas {
      background-image: url('sensors.png');
      background-repeat: no-repeat;
      background-size: contain;
    }
  </style>

  <script type='text/coffeescript'>
    @ctx = ctx = @canvas.getContext('2d')
    canvas = @canvas

    receive 'quality', (quality) =>
      @quality = quality
      @update()

    @on 'update', ->
      return if @drawing
      @drawing = true
      requestAnimationFrame draw

    pt = (x, y) -> {x: x / 400, y: y / 400}

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


    #canvas.addEventListener 'click', (e) ->
    #  console.log "e", e.layerX, e.layerY
    #  ctx.clearRect(0, 0, canvas.width, canvas.height)
    #  ctx.fillStyle = "black"
    #  ctx.textAlign = "left"
    #  ctx.beginPath()
    #  ctx.arc(e.layerX, e.layerY, 20, 0, Math.PI*2)
    #  ctx.closePath()
    #  ctx.fill()
    #  ctx.fillText("#{e.layerX},#{e.layerY}", e.layerX+30, e.layerY)


    draw = =>
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      @drawing = false
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillStyle = 'black'
      ctx.font = '48px Helvetica,sans-serif'
      ctx.fillText('Quality', canvas.width / 2, canvas.height / 2 + 32)
      ctx.font = '12px Helvetica,sans-serif'
      return unless @quality

      QUALITY_MAX = 5
      for sensor, loc of LOCATIONS
        x = loc.x * canvas.width
        y = loc.y * canvas.height
        ctx.beginPath()
        ctx.arc(x, y, 20, 0, Math.PI * 2)
        ctx.closePath()
        greenness = Math.min(@quality[sensor] / QUALITY_MAX, 1)
        ctx.fillStyle = "rgb(#{Math.round((1 - greenness) * 255)}, #{Math.round(greenness * 255)}, 0)"
        ctx.fill()
        ctx.fillStyle = 'black'
        ctx.fillText(sensor, x, y)

  </script>

</brainweb-quality>
