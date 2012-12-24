# https://github.com/midnightcodr/socketio_flot/blob/master/public/javascripts/main.js

# we use an inline data source in the example, usually data would
# be fetched from a server
@getRandomData = ->
  data = data.slice(1)  if data.length > 0

  # do a random walk
  while data.length < totalPoints
    prev = (if data.length > 0 then data[data.length - 1] else 50)
    y = prev + Math.random() * 10 - 5
    y = 0  if y < 0
    y = 100  if y > 100
    data.push y

  # zip the generated y values with the x values
  res = []
  i = 0

  while i < data.length
    res.push [i, data[i]]
    ++i
  res

# setup control widget

# setup plot
# drawing is faster without shadows

#@update = ->
#  plot.setData [getRandomData()]
#
#  # since the axes don't change, we don't need to call plot.setupGrid()
#  plot.draw()
#  setTimeout update, updateInterval
#
#plot = $.plot($("#route_height_chart"), [getRandomData()], options)
#update()

@realtime_graph_init = (container) ->
  # some options
  graph_data = []
  totalPoints = 100
  updateInterval = 30
  options =
    series:
      shadowSize: 0

    yaxis:
      min: 0
      max: 45

    xaxis:
      show: false

  # initial data
  x = 0
  while x < totalPoints
    graph_data.push([x, 0.0])
    x++

  # plot initial graph
  plot = $.plot($("#route_height_chart"), [graph_data], options)

  # start the magic
  socket = io.connect("http://localhost:8080")
  socket.on "message", (data) ->
    d = JSON.parse(data)
    if d["meas"]
      if d["meas"]["name"] == "batt_u"
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
