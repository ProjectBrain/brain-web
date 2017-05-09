riot = require('riot')
THREE = require('three')
STLLoader = require('three-stl-loader')(THREE)
OrbitControls = require('three-orbit-controls')(THREE)

<brainweb-3d>

  <canvas name="canvas" width={ opts.width } height={ opts.height }></canvas>

  <style scoped>
    :scope {
      display: block;
    }
  </style>

  <script type='text/coffeescript'>

    LOCATIONS =
      AF3: x: 0.4, y: 0.2, z: 1
      AF4: x: -0.4, y: 0.2, z: 1
      F7:  x: 0.8, y: 0, z: 0.8
      F8:  x: -0.8, y: 0, z: 0.8
      F3:  x: 0.6, y: 1, z: 0.5
      F4:  x: -0.6, y: 1, z: 0.5
      FC5: x: 0.8, y: 0.5, z:0.7
      FC6: x: -0.8, y: 0.5, z:0.7
      T7:  x: 1, y: 0, z: 0.2
      T8:  x: -1, y: 0, z: 0.2
      P7:  x: 0.8, y: 0, z:-0.2
      P8:  x: -0.8, y: 0, z:-0.2
      O1:  x: 0.4, y: 0, z:-0.8
      O2:  x: -0.4, y: 0, z:-0.8

    camera = new THREE.PerspectiveCamera 20, opts.width / opts.height, 1, 10000
    angle = 0
    radius = 1800
    camera.position.z = radius

    controls = new OrbitControls(camera)
    controls.enableZoom = false

    scene = new THREE.Scene

    sensors = {}

    addSensor = (col, x, y, z) ->
      # light = new THREE.DirectionalLight col
      light = new THREE.SpotLight col

      light.position.set x, y, z
      light.intensity = 0.3
      geometry = new THREE.IcosahedronGeometry 10
      material = new THREE.MeshBasicMaterial(
        color: col
        shading: THREE.FlatShading
      )
      mesh = new THREE.Mesh(geometry, material)
      # mesh.position.set x, y, z

      scene.add light
      # scene.add mesh
      {light, mesh, geometry, material}

    for label, pos of LOCATIONS
      sensors[label] = addSensor 0xff00ff, pos.x * 200, pos.y * 200, pos.z * 300
      # sensors[label] = addSensor 0xff00ff, pos.x * 150, pos.y * 150, pos.z * 250

    # addSensor 0xff0000, 0, 0, 250
    # addSensor 0x00ff00, 0, 150, 0
    # addSensor 0x0000ff, 150, 0, 0


    # light = new THREE.DirectionalLight 0xff0000
    # light.position.set 0, 0, 1
    # scene.add light

    # light2 = new THREE.DirectionalLight 0x00ff00
    # light2.position.set 1, 0, 1
    # scene.add light2


    # light3 = new THREE.DirectionalLight 0x0000ff
    # light3.position.set -1, 0, 1
    # scene.add light3

    faceIndices = [
      'a'
      'b'
      'c'
    ]

    color = undefined
    f = undefined
    f2 = undefined
    f3 = undefined
    p = undefined
    vertexIndex = undefined
    radius = 200
    geometry = new THREE.IcosahedronGeometry radius, 1
    geometry2 = new THREE.IcosahedronGeometry radius, 1
    geometry3 = new THREE.IcosahedronGeometry radius, 1
    i = 0
    console.log "geometry length", geometry.faces.length
    while i < geometry.faces.length
      f = geometry.faces[i]
      f2 = geometry2.faces[i]
      f3 = geometry3.faces[i]
      j = 0
      while j < 3
        vertexIndex = f[faceIndices[j]]
        p = geometry.vertices[vertexIndex]
        color = new THREE.Color 0xffffff
        color.setHSL (p.y / radius + 1) / 2, 1.0, 0.5
        f.vertexColors[j] = color
        color = new THREE.Color 0xffffff
        color.setHSL 0.0, (p.y / radius + 1) / 2, 0.5
        f2.vertexColors[j] = color
        color = new THREE.Color 0xffffff
        color.setHSL 0.125 * vertexIndex / geometry.vertices.length, 1.0, 0.5
        f3.vertexColors[j] = color
        j++
      i++

    materials = [
      new THREE.MeshPhongMaterial(
        color: 0xffffff
        shading: THREE.FlatShading
        vertexColors: THREE.VertexColors
        shininess: 0
      )
      new THREE.MeshBasicMaterial(
        color: 0x000000
        shading: THREE.FlatShading
        wireframe: true
        transparent: true
      )
    ]

    group1 = THREE.SceneUtils.createMultiMaterialObject(geometry, materials)
    group1.position.x = -400
    group1.rotation.x = -1.87
    # scene.add group1

    group2 = THREE.SceneUtils.createMultiMaterialObject(geometry2, materials)
    group2.position.x = 400
    group2.rotation.x = 0
    # scene.add group2

    group3 = THREE.SceneUtils.createMultiMaterialObject(geometry3, materials)
    group3.position.x = 0
    group3.rotation.x = 0
    # scene.add group3

    loader = new STLLoader()

    wat = null

    loader.load 'models/brain.stl', (geometry) ->
      # material = new THREE.MeshNormalMaterial()
      # material = new THREE.MeshBasicMaterial(
      #   color: 0xffffff
      #   shading: THREE.FlatShading
      #   # wireframe: true
      #   # transparent: true
      # )
      material = new THREE.MeshPhongMaterial(
        color: 0xffffff
        shading: THREE.FlatShading
        shininess: 10
      )

      mesh = new THREE.Mesh(geometry, material)
      mesh.scale.set 2, 2, 2
      mesh.rotation.x = -Math.PI/2
      wat = mesh
      scene.add(mesh)


    renderer = new THREE.WebGLRenderer antialias: true, canvas: @canvas
    # renderer = new THREE.WebGLRenderer antialias: true
    renderer.setClearColor 0xffffff
    renderer.setPixelRatio window.devicePixelRatio
    renderer.setSize opts.width, opts.height

    # @container.appendChild renderer.domElement

    render = ->
      requestAnimationFrame render
      renderer.render scene, camera
      # if wat
        # wat.rotation.x += 0.005
        # wat.rotation.y += 0.008
        # wat.rotation.z += 0.008
        # wat.rotation.z += 0.03
      # group1.rotation.x += 0.01
      # group2.rotation.y += 0.01
      # group3.rotation.z += 0.01
      # camera.position.x = radius * Math.cos angle
      # camera.position.z = radius * Math.sin angle
      # if wat
        # camera.lookAt wat
      angle += 0.01


    render()

    receive 'bands', (bands) =>
      idx = 0
      for sensor, data of sensors

        # x = loc.x * canvas.width
        # y = loc.y * canvas.height
        # ctx.beginPath()
        # ctx.arc(x, y, smallradius, 0, Math.PI * 2)
        # ctx.closePath()
        # ctx.fillStyle = 'white'
        # #ctx.fill()

        # ctx.beginPath()
        # ctx.arc(x, y, bigradius, 0, Math.PI * 2)
        # ctx.closePath()
        brightness = 0.2
        r = Math.min(bands.beta[idx] / bands.total[idx] + brightness, 1)
        g = Math.min(bands.theta[idx] / bands.total[idx] + brightness, 1)
        b = Math.min(bands.alpha[idx] / bands.total[idx] + brightness, 1)

        # console.log "color", r, g, b
        data.light.color.setRGB r, g, b
        data.material.color.setRGB r, g, b

        idx++

        # gradient = ctx.createRadialGradient(x, y, bigradius, x, y, 0)
        # gradient.addColorStop(0, "rgba(#{Math.round(redness * 255)}, #{Math.round(greenness * 255)}, #{Math.round(blueness * 255)}, 0)")
        # #gradient.addColorStop(0.2, "rgba(#{Math.round(redness*255)},#{Math.round(greenness*255)},#{Math.round(blueness*255)},0.1)")
        # gradient.addColorStop(1, "rgba(#{Math.round(redness * 255)}, #{Math.round(greenness * 255)}, #{Math.round(blueness * 255)}, 1)")
        # #ctx.fillStyle = "rgba(#{Math.round(redness*255)},#{Math.round(greenness*255)},#{Math.round(blueness*255)},0.5)"
        # ctx.fillStyle = gradient
        # ctx.fill()
        #ctx.fillStyle = "black"
        #ctx.fillText(sensor, x, y-8)

    # console.log "opts", opts, @opts
    # console.log "canvas", @canvas, @width, @height

    # renderer.gammaInput = true
    # renderer.gammaOutput = true
    # renderer.shadowMap.enabled = true
    # renderer.shadowMap.renderReverseSided = false
    # container.appendChild( renderer.domElement )
    # @ctx = ctx = @canvas.getContext('2d')
    # canvas = @canvas

    # receive 'freqs', (freqs) =>
    #   @freqs = freqs
    #   @update()

    # @on 'update', ->
    #   return if @drawing
    #   @drawing = true
    #   requestAnimationFrame draw


    # line = (x1, y1, x2, y2, color) ->
    #   #console.log("x1", x1, "y1", y1, "x2", x2, "y2", y2, "color", color) if x1 == 0
    #   ctx.strokeStyle = color
    #   ctx.beginPath()
    #   ctx.moveTo(x1, y1)
    #   ctx.lineTo(x2, y2)
    #   ctx.stroke()


    # LOCATIONS = ['AF3', 'AF4', 'F7', 'F8', 'F3', 'F4', 'FC5', 'FC6', 'T7', 'T8', 'P7', 'P8', 'O1', 'O2']

    # draw = =>
    #   @drawing = false
    #   return unless @freqs
    #   ctx.clearRect(0, 0, canvas.width, canvas.height)
    #   ctx.textAlign = 'left'
    #   margin = 16
    #   bottom = canvas.height
    #   xscale = canvas.width / @freqs.freq.length
    #   xscale *= 2
    #   for powers, i in @freqs.psd.slice(0, 14)
    #     continue if @quality and @quality[LOCATIONS[i]] < 5
    #     hue = Math.round(i / @freqs.psd.length * 255)
    #     ctx.strokeStyle = "hsl(#{hue}, 50%, 75%)"
    #     ctx.fillStyle = "hsl(#{hue}, 50%, 75%)"
    #     ctx.fillText LOCATIONS[i], 0, i / LOCATIONS.length * canvas.height
    #     ctx.beginPath()
    #     for y, x in powers
    #       #y = y / 100
    #       #y = Math.log(y)*10
    #       if x == 0
    #         ctx.moveTo(x + margin, bottom - y - margin)
    #       else
    #         ctx.lineTo(x * xscale + margin, bottom - y - margin)
    #     ctx.stroke()
    #   ctx.textAlign = 'center'
    #   ctx.fillStyle = 'black'
    #   for freq, x in @freqs.freq
    #     ctx.fillText freq, x * xscale, bottom if freq % 1 == 0

  </script>

</brainweb-3d>
