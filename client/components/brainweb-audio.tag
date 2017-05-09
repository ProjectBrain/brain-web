riot = require('riot')

<brainweb-audio>
  <form>
    <input type="radio" onclick="{ set }" value="linear" checked="{ mode == 'linear' }" />Linear
    <input type="radio" onclick="{ set }" value="exponential" checked="{ mode == 'exponential' }" />Exponential
    <input type="radio" onclick="{ set }" value="pentatonic" checked="{ mode == 'pentatonic' }" />Pentatonic
    <input type="radio" onclick="{ set }" value="equal" checked="{ mode == 'equal' }" />Equal
    <input type="radio" onclick="{ set }" value="off" checked="{ mode == 'off' }" />Off
  </form>

  <script type='text/coffeescript'>
    @mode = "off"

    @ctx = ctx = new AudioContext()
    window.audioctx = ctx

    receive 'freqs', (freqs) =>
      @freqs = freqs
      @update()

    # setInterval =>
    #   @update()
    # , 1000

    window.mode = @mode
    LOWEST_AUDIO = 150
    HIGHEST_AUDIO = 2000 #4995.026783828026 #4067.4536 #4645.0308839 #10174.961115 #15000 #2248 #4296
    LOWEST_EEG = 0
    HIGHEST_EEG = 32
    NUM_OSCS = 4 * 4

    N_TET = 12
    OCTAVES = Math.log2(HIGHEST_AUDIO) - Math.log2(LOWEST_AUDIO)
    NUM_OCTAVES = 4

    music = [
      220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00,
      440.00, 493.88, 523.25, 587.33, 659.25, 698.46, 783.99,
      880.00, 987.77, 1046.50, 1174.66, 1318.51, 1396.61, 1567.98,
      1760.00, 1975.53, 2093.00, 2349.32, 2637.02, 2793.83, 3135.96, 3520.00]
    pentatonic = [
      #103.83, 116.54, 138.59, 155.56, 185.00,
      155.56, 185.00,
      207.65, 233.08, 277.18, 311.13, 369.99,
      415.30, 466.16, 554.37, 622.25, 739.99,
      830.61, 932.33, 1108.73, 1244.51, 1479.98,
      1661.22, 1864.66, 2217.46, 2489.02, 2959.96,
      3322.44, 3729.31, 4434.92, 4978.03, 5919.91,
      6644.88, 7458.62
    ]
    LOWEST_PENT = pentatonic[0]
    HIGHEST_PENT = pentatonic[pentatonic.length - 1]
    oscs = []
    gains = []

    window.oscs = oscs
    window.gains = gains
    base = Math.exp(Math.log(HIGHEST_AUDIO / LOWEST_AUDIO) / (NUM_OSCS - 1))
    console.log 'base', base

    maingain = ctx.createGain()
    maingain.connect ctx.destination

    getFreq = (i) =>
      console.log 'mode', @mode
      switch @mode
        when 'linear'
          i * (HIGHEST_AUDIO - LOWEST_AUDIO) / (NUM_OSCS - 1) + LOWEST_AUDIO #linear
        when 'exponential'
          LOWEST_AUDIO * Math.pow(base, i) #exponential
        when 'pentatonic'
          pentatonic[i] or 0#* ((HIGHEST_AUDIO - LOWEST_AUDIO) / (HIGHEST_PENT - LOWEST_PENT)) + (LOWEST_AUDIO - LOWEST_PENT) or 0
        when 'equal'
          LOWEST_AUDIO * Math.pow(2, i / (NUM_OSCS / NUM_OCTAVES))
        when 'off'
          0


    @set = (e) =>
      @update mode: e.target.value
      for i in [0...NUM_OSCS]
        oscs[i].frequency.value = getFreq(i)

    do ->
      for i in [0...NUM_OSCS]
        #console.log "i", i, "music", music[i]
        osc = ctx.createOscillator()
        osc.frequency.value = getFreq(i)
        oscs.push osc
        gain = ctx.createGain()
        gain.gain.value = 0
        gains.push gain

        osc.connect gain
        gain.connect maingain
        osc.start()

    getPSD = (freq) =>
      f = @freqs.freq
      p = []
      for psd, sensor in @freqs.psd
        for power, i in psd
          p[i] = Math.max(p[i] || 0, power)

      #console.log "POWERAR", p
      range = f[f.length - 1] - f[0]
      i = ((freq - f[0]) / range) * (f.length - 1)
      # console.log "i", i, "freq", freq, "range", range, "f[0]", f[0], "f[f.length-1]", f[f.length-1]
      if p[i]
        p[i]
      else
        previ = Math.floor(i)
        nexti = Math.ceil(i)
        # console.log "i", i, "previ", previ, "nexti", nexti
        d = p[previ] * (i - previ) + p[nexti] * (nexti - i)
        # console.log "d", d, "p[previ]", p[previ], "i-previ", i-previ, "p[nexti]", p[nexti], "nexti-i", nexti-i
        d / 2




    @on 'update', ->
      return unless @freqs
      #console.log "freqs", @freqs.freq
      total = 0
      max = 0
      #console.log JSON.stringify @freqs.freq
      # for freq, i in @freqs.freq
      #   continue unless freq >= LOWEST_EEG and freq <= HIGHEST_EEG
      #
      #   osc_i = (freq - LOWEST_EEG) / (HIGHEST_EEG - LOWEST_EEG) * NUM_OSCS
      #   for psds in @freqs.psd
      #     total += psds[i]
      #     max = psds[i] if psds[i] > max
      #   continue unless gains[osc_i]
      #   avg = total / psds.length
      #   #console.log "psd", psd
      #   gain = Math.min(max/1000, 1)
      #   gain = max
      #   #console.log "setting gain at freq #{freq} (audio #{oscs[osc_i].frequency.value}) (index #{osc_i}) to #{gain} (max #{max})" if gain > 0.2
      #   gains[osc_i].gain.value = gain
      #   total = 0
      #   max = 0

      newgains = []
      totalgain = 0
      for gain, i in gains
        # console.log "i", i, "freq", i / gains.length * (HIGHEST_EEG - LOWEST_EEG) + LOWEST_EEG
        p = getPSD(i / gains.length * (HIGHEST_EEG - LOWEST_EEG) + LOWEST_EEG) or 0
        #console.log "i", i, "p", p
        totalgain += p
        newgains.push p

      for gain, i in gains
        gain.gain.value = newgains[i] / totalgain or 0


      maingain.gain.value = 1 #Math.min(1, 1/totalgain or 0)
      #console.log "totalgain", totalgain, "maingain", maingain.gain.value

  </script>

</brainweb-audio>
