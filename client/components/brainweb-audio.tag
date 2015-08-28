riot = require('riot')

<brainweb-audio>
  <form>
    <input type="radio" onclick="{ set }" value="linear" checked="{{ mode == 'linear' }}">Linear
    <input type="radio" onclick="{ set }" value="exponential" checked="{{ mode == 'exponential' }}">Exponential
    <input type="radio" onclick="{ set }" value="pentatonic" checked="{{ mode == 'pentatonic' }}">Pentatonic
  </form>
  <script type='coffeescript'>
    @mode = "pentatonic"

    @ctx = ctx = new AudioContext()
    window.audioctx = ctx

    receive 'freqs', (freqs) =>
      @freqs = freqs
      @update()

    window.mode = @mode
    LOWEST_AUDIO = 100
    HIGHEST_AUDIO = 7000 #4995.026783828026 #4067.4536 #4645.0308839 #10174.961115 #15000 #2248 #4296
    LOWEST_EEG = 0
    HIGHEST_EEG = 32
    NUM_OSCS = 32

    music = [
      220.00, 246.94, 261.63, 293.66, 329.63, 349.23, 392.00,
      440.00, 493.88, 523.25, 587.33, 659.25, 698.46, 783.99,
      880.00, 987.77, 1046.50, 1174.66, 1318.51, 1396.61, 1567.98,
      1760.00, 1975.53, 2093.00, 2349.32, 2637.02, 2793.83, 3135.96, 3520.00]
    pentatonic = [
      103.83, 116.54, 138.59, 155.56, 185.00,
      207.65, 233.08, 277.18, 311.13, 369.99,
      415.30, 466.16, 554.37, 622.25, 739.99,
      830.61, 932.33, 1108.73, 1244.51, 1479.98,
      1661.22, 1864.66, 2217.46, 2489.02, 2959.96,
      3322.44, 3729.31, 4434.92, 4978.03, 5919.91,
      6644.88, 7458.62
    ]
    LOWEST_PENT = pentatonic[0]
    HIGHEST_PENT = pentatonic[pentatonic.length-1]
    oscs = []
    gains = []

    window.oscs = oscs
    window.gains = gains
    base = Math.exp(Math.log(HIGHEST_AUDIO/LOWEST_AUDIO)/NUM_OSCS)
    console.log "base", base

    maingain = ctx.createGain()
    maingain.connect ctx.destination

    @set = (e) =>
      @update mode: e.target.value
      for i in [0...NUM_OSCS]
        if @mode is 'linear'
          freq = i * (HIGHEST_AUDIO - LOWEST_AUDIO)/NUM_OSCS + LOWEST_AUDIO #linear
        else if @mode is 'exponential'
          freq = LOWEST_AUDIO * Math.pow(base, i) #exponential
        else if @mode is 'pentatonic'
          freq = pentatonic[i] * ((HIGHEST_AUDIO - LOWEST_AUDIO) / (HIGHEST_PENT - LOWEST_PENT)) + (LOWEST_AUDIO - LOWEST_PENT)
        oscs[i].frequency.value = freq

    for i in [0...NUM_OSCS]
      if @mode is 'linear'
        freq = i * (HIGHEST_AUDIO - LOWEST_AUDIO)/NUM_OSCS + LOWEST_AUDIO #linear
      else if @mode is 'exponential'
        freq = LOWEST_AUDIO * Math.pow(base, i) #exponential
      else if @mode is 'pentatonic'
        freq = pentatonic[i] * ((HIGHEST_AUDIO - LOWEST_AUDIO) / (HIGHEST_PENT - LOWEST_PENT)) + (LOWEST_AUDIO - LOWEST_PENT)
      #console.log "i", i, "music", music[i]
      osc = ctx.createOscillator()
      osc.frequency.value = freq
      oscs.push osc
      gain = ctx.createGain()
      gain.gain.value = 0
      gains.push gain

      osc.connect gain
      gain.connect maingain
      osc.start()
    @on 'update', ->
      return unless @freqs
      #console.log "freqs", @freqs.freq
      total = 0
      max = 0
      for freq, i in @freqs.freq
        continue unless freq >= LOWEST_EEG and freq <= HIGHEST_EEG

        osc_i = (freq - LOWEST_EEG) / (HIGHEST_EEG - LOWEST_EEG) * NUM_OSCS
        for psds in @freqs.psd
          total += psds[i]
          max = psds[i] if psds[i] > max
        continue unless gains[osc_i]
        avg = total / psds.length
        #console.log "psd", psd
        gain = Math.min(max/1000, 1)
        gain = max
        #console.log "setting gain at freq #{freq} (audio #{oscs[osc_i].frequency.value}) (index #{osc_i}) to #{gain} (max #{max})" if gain > 0.2
        gains[osc_i].gain.value = gain
        total = 0
        max = 0

      totalgain = 0
      for gain in gains
        totalgain += gain.gain.value

      maingain.gain.value = Math.min(1, 1/totalgain or 0)
      #console.log "totalgain", totalgain, "maingain", maingain.gain.value

  </script>

</brainweb-audio>
