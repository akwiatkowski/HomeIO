# https://github.com/midnightcodr/socketio_flot/blob/master/public/javascripts/main.js

# TODO: autoaxis refresh

@realtime_graph_init = (container) ->
  # some options
  graph_data = []
  totalPoints = 400
  updateInterval = 30
  options =
    series:
      shadowSize: 0

    yaxis:
      min: 0
      max: 10.0

    xaxis:
      show: false

  # initial data
  x = 0
  while x < totalPoints
    graph_data.push([x, 0.0])
    x++

  # plot initial graph
  plot = $.plot($(container), [graph_data], options)

  # start the magic
  socket = io.connect("http://localhost:8080")
  socket.on "message", (data) ->
    d = JSON.parse(data)
    if d["meas"]
      #if d["meas"]["name"] == "batt_u"
      if d["meas"]["name"] == "i_gen_batt"
        v = Math.round(d["meas"]["value"] * 100) / 100;
        console.log(d)

        # adding new value
        graph_data = graph_data.slice(1)

        new_graph_data = []
        x = 0
        while x < (totalPoints - 1)
          new_graph_data.push([x, graph_data[x][1]])
          x++
        # add new value
        new_point = [totalPoints - 1, v]
        console.log new_point
        new_graph_data.push(new_point)

        graph_data = new_graph_data

        plot.setData [graph_data]
        plot.setupGrid()
        plot.draw()

        #console.log v
