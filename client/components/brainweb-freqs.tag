riot = require('riot')

<brainweb-freqs>

  <canvas name="canvas" width={ opts.width } height={ opts.height }></canvas>

  <style scoped>
    :scope {
      display: block;
    }
  </style>

  <script type='text/coffeescript'>
    @ctx = ctx = @canvas.getContext('2d')
    canvas = @canvas

    receive 'freqs', (freqs) =>
      @freqs = freqs
      @update()

    @on 'update', ->
      return if @drawing
      @drawing = true
      requestAnimationFrame draw


    line = (x1, y1, x2, y2, color) ->
      #console.log("x1", x1, "y1", y1, "x2", x2, "y2", y2, "color", color) if x1 == 0
      ctx.strokeStyle = color
      ctx.beginPath()
      ctx.moveTo(x1, y1)
      ctx.lineTo(x2, y2)
      ctx.stroke()


    LOCATIONS = ['AF3', 'AF4', 'F7', 'F8', 'F3', 'F4', 'FC5', 'FC6', 'T7', 'T8', 'P7', 'P8', 'O1', 'O2']

    draw = =>
      @drawing = false
      return unless @freqs
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      ctx.textAlign = 'left'
      margin = 16
      bottom = canvas.height
      xscale = canvas.width / @freqs.freq.length
      xscale *= 2
      for powers, i in @freqs.psd.slice(0, 14)
        continue if @quality and @quality[LOCATIONS[i]] < 5
        hue = Math.round(i / @freqs.psd.length * 255)
        ctx.strokeStyle = "hsl(#{hue}, 50%, 75%)"
        ctx.fillStyle = "hsl(#{hue}, 50%, 75%)"
        ctx.fillText LOCATIONS[i], 0, i / LOCATIONS.length * canvas.height
        ctx.beginPath()
        for y, x in powers
          #y = y / 100
          #y = Math.log(y)*10
          if x == 0
            ctx.moveTo(x + margin, bottom - y - margin)
          else
            ctx.lineTo(x * xscale + margin, bottom - y - margin)
        ctx.stroke()
      ctx.textAlign = 'center'
      ctx.fillStyle = 'black'
      for freq, x in @freqs.freq
        ctx.fillText freq, x * xscale, bottom if freq % 1 == 0

  </script>

</brainweb-freqs>
