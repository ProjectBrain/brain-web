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

  <script type='coffeescript'>
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

    draw = =>
      @drawing = false
      return unless @fractal
      ctx.textAlign = "center"
      ctx.textBaseline = "middle"
      FRACTAL_MIN = 1
      FRACTAL_MAX = 2
      for sensor, i in LOCATIONS_A
        loc = LOCATIONS[sensor]
        ctx.beginPath()
        ctx.arc(loc.x, loc.y, 20, 0, Math.PI*2)
        ctx.closePath()
        redness = Math.min((@fractal[i]-FRACTAL_MIN)/(FRACTAL_MAX-FRACTAL_MIN),1)
        ctx.fillStyle = "rgb(#{Math.round(redness*255)}, 0, #{Math.round((1-redness)*255)})"
        ctx.fill()
        ctx.fillStyle = "white"
        #ctx.fillText(sensor, loc.x, loc.y-8)
        ctx.fillText(@fractal[i].toFixed(2), loc.x, loc.y+8)

  </script>

</brainweb-fractal>
