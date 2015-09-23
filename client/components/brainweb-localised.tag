riot = require('riot')

<brainweb-localised>

  <canvas name="canvas" width={ opts.width } height={ opts.height }></canvas>

  <style scoped>
    :scope {
      display: block;
      /*flex: 0 1 auto;*/
    }
    canvas {
      /*background-image: url('sensors.png');*/
      background-repeat: no-repeat;
      background-size: contain;
    }
  </style>

  <script type='text/coffeescript'>
    @ctx = ctx = @canvas.getContext('2d')
    canvas = @canvas

    receive 'bands', (bands) =>
      @bands = bands
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
      return unless @bands
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      #SE
      idx = 0
      radius = Math.min(canvas.height, canvas.width) / 2
      smallradius = 25 / 400 * canvas.height
      bigradius = 150 / 400 * canvas.height
      ctx.beginPath()
      ctx.arc(canvas.width / 2, canvas.height / 2, radius, 0, Math.PI * 2)
      ctx.closePath()
      ctx.clip()

      for sensor, loc of LOCATIONS
        x = loc.x * canvas.width
        y = loc.y * canvas.height
        ctx.beginPath()
        ctx.arc(x, y, smallradius, 0, Math.PI * 2)
        ctx.closePath()
        ctx.fillStyle = 'white'
        #ctx.fill()

        ctx.beginPath()
        ctx.arc(x, y, bigradius, 0, Math.PI * 2)
        ctx.closePath()
        brightness = 0.2
        redness = Math.min(@bands.beta[idx] / @bands.total[idx] + brightness, 1)
        greenness = Math.min(@bands.theta[idx] / @bands.total[idx] + brightness, 1)
        blueness = Math.min(@bands.alpha[idx] / @bands.total[idx] + brightness, 1)
        gradient = ctx.createRadialGradient(x, y, bigradius, x, y, 0)
        gradient.addColorStop(0, "rgba(#{Math.round(redness * 255)}, #{Math.round(greenness * 255)}, #{Math.round(blueness * 255)}, 0)")
        #gradient.addColorStop(0.2, "rgba(#{Math.round(redness*255)},#{Math.round(greenness*255)},#{Math.round(blueness*255)},0.1)")
        gradient.addColorStop(1, "rgba(#{Math.round(redness * 255)}, #{Math.round(greenness * 255)}, #{Math.round(blueness * 255)}, 1)")
        #ctx.fillStyle = "rgba(#{Math.round(redness*255)},#{Math.round(greenness*255)},#{Math.round(blueness*255)},0.5)"
        ctx.fillStyle = gradient
        ctx.fill()
        #ctx.fillStyle = "black"
        #ctx.fillText(sensor, x, y-8)
        idx++

  </script>

</brainweb-localised>
