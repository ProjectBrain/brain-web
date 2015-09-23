riot = require('riot')

<brainweb-entropy>

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

    receive 'entropy', (entropy) =>
      #console.log "entropy", entropy
      @entropy = entropy
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
      ctx.fillText('Entropy', canvas.width / 2, canvas.height / 2 + 32)
      ctx.font = '12px Helvetica,sans-serif'
      return unless @entropy

      ENTROPY_MIN = 3
      ENTROPY_MAX = 6
      # ENTROPY_MIN = 0.6
      # ENTROPY_MAX = 0.8
      for sensor, i in LOCATIONS_A
        loc = LOCATIONS[sensor]
        x = loc.x * canvas.width
        y = loc.y * canvas.height
        ctx.beginPath()
        ctx.arc(x, y, 20, 0, Math.PI * 2)
        ctx.closePath()
        value = Math.min((@entropy[i] - ENTROPY_MIN) / (ENTROPY_MAX - ENTROPY_MIN), 1)
        ctx.fillStyle = "rgb(255, #{Math.round((1 - value) * 255)}, 255)"
        ctx.fill()
        ctx.fillStyle = 'black'
        ctx.fillText(@entropy[i].toFixed(2), x, y)

  </script>

</brainweb-entropy>
