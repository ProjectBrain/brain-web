riot = require('riot')

<brainweb-fractal>

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

    receive 'fractal', (fractal) =>
      #console.log "FRACTAL", fractal
      @fractal = fractal
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

    draw = =>
      @drawing = false
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillStyle = 'black'
      ctx.font = '48px Helvetica,sans-serif'
      ctx.fillText('Fractal', canvas.width / 2, canvas.height / 2 + 32)
      ctx.font = '12px Helvetica,sans-serif'
      return unless @fractal

      FRACTAL_MIN = 1
      FRACTAL_MAX = 2
      for sensor, i in LOCATIONS_A
        loc = LOCATIONS[sensor]
        x = loc.x * canvas.width
        y = loc.y * canvas.height
        ctx.beginPath()
        ctx.arc(x, y, 20, 0, Math.PI * 2)
        ctx.closePath()
        redness = Math.min((@fractal[i] - FRACTAL_MIN) / (FRACTAL_MAX - FRACTAL_MIN), 1)
        ctx.fillStyle = "rgb(#{Math.round(redness * 255)}, 0, #{Math.round((1 - redness) * 255)})"
        ctx.fill()
        ctx.fillStyle = 'white'
        ctx.fillText(@fractal[i].toFixed(2), x, y)

  </script>

</brainweb-fractal>
