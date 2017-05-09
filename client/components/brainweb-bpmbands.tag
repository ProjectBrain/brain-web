riot = require('riot')

<brainweb-bpmbands>

  <canvas name="canvas" width={ opts.width } height={ opts.height }></canvas>

  <style scoped>
    :scope {
      display: block;
    }
  </style>

  <script type='text/coffeescript'>
    @ctx = ctx = @canvas.getContext('2d')
    canvas = @canvas

    receive 'bpmbands', (bands) =>
      @bands = bands
      @update()

    @on 'update', ->
      return if @drawing
      @drawing = true
      #draw()
      requestAnimationFrame draw


    BANDS = ['bpm/2', 'bpm', 'bpm2', 'bpm4']

    draw = =>
      @drawing = false
      return unless @bands
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      ctx.textAlign = 'center'
      i = 0
      margin = 16
      width = (canvas.width - margin * 2) / BANDS.length

      for band in BANDS
        powers = @bands[band]
        for power, sensor in powers
          hue = Math.round(sensor / powers.length * 255)
          total = @bands[band + 'env'][sensor]
          <!-- scaledpower = Math.max(power * 2 - total, 0) -->
          scaledpower = Math.max(0, power * 2 / total - 1)
          #console.log 'sensor', sensor, 'global', @bands.global[sensor]
          ctx.fillStyle = "hsla(#{hue}, 50%, 75%, 0.2)"
          ctx.fillRect((i * width) + margin, canvas.height - 16, width, -scaledpower * canvas.height)
          #ctx.fillRect((i*width)+16, canvas.height-16, width, -(Math.log(power)-5)*20)

        ctx.fillStyle = 'black'
        ctx.fillText("#{band}", (i * width) + margin + width / 2, canvas.height - 16)
        i++


  </script>

</brainweb-bpmbands>
