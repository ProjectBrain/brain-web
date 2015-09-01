riot = require('riot')

<brainweb-entropy-logger>

  <h1>Entropy!</h1>
  <b>Current:</b> {{avg}} <br />
  <b>Average:</b> {{cma}} <br />
  <button onclick="{{reset}}">reset</button>

  <style scoped>
    :scope {
      display: block;
    }
  </style>

  <script type='coffeescript'>
    receive 'entropy', (entropy) =>
      #console.log "entropy", entropy
      @entropy = entropy
      @update()

    @on 'update', ->
      return unless @entropy
      sum = 0
      count = 0
      for x in @entropy when x < 200
        count++
        sum += x
      @avg = sum / count
      return if sum is 0

      if @n is 0
        @cma = @avg
      else
        @cma = (@cma * @n + @avg) / (@n + 1)
      @n++

    @n = 0
    @reset = =>
      @n = 0

  </script>

</brainweb-entropy-logger>
