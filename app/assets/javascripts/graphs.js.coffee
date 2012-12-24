@graph_init = (container)->
# https://github.com/midnightcodr/socketio_flot/blob/master/public/javascripts/main.js


data = []
totalPoints = 300
updateInterval = 30
options =
  series:
    shadowSize: 0

  yaxis:
    min: 0
    max: 100

  xaxis:
    show: false

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
@update = ->
  plot.setData [getRandomData()]

  # since the axes don't change, we don't need to call plot.setupGrid()
  plot.draw()
  setTimeout update, updateInterval

plot = $.plot($("#route_height_chart"), [getRandomData()], options)
update()