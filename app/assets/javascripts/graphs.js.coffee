@realtime_graph_init = (container, types) ->
  first_time = null
  graph_data = []
  i = 0
  while i < types.length
    graph_data[i] = []
    i++

  totalPoints = 400

  options =
    series:
      shadowSize: 0
      lines:
        show: true

    xaxis:
      show: true

  # initial data
#  x = 0
#  while x < totalPoints
#    i = 0
#    while i < types.length
#      graph_data[i].push([x, 0.0])
#      i++
#    x++

  # plot initial graph
  plot = $.plot($(container), graph_data, options)

  # start the magic
  socket = io.connect("http://localhost:8080")
  socket.on "message", (data) ->
    d = JSON.parse(data)
    if d["meas"]
      i = 0
      while i < types.length
        type = types[i]
        if d["meas"]["name"] == type
          # adding measurement to graph
          v = Math.round(d["meas"]["value"] * 100) / 100;
          t = d["meas"]["time"]

          if first_time == null
            first_time = t

          if graph_data[i].length >= totalPoints
            graph_data[i] = graph_data[i].slice(1)

          # add new value
          new_point = [t - first_time, v]
          graph_data[i].push(new_point)

          plot.setData graph_data
          plot.setupGrid()
          plot.draw()

        i++
