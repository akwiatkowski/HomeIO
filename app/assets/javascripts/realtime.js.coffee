@realtime_init = ->
  socket = io.connect("http://localhost:8080")
  socket.on "message", (data) ->
    d = JSON.parse(data)
    if d["meas"]
      realtime_put_value(d["meas"]["name"], d["meas"]["value"])

@realtime_put_value = (name, value) ->
  place_selector = "#data #" + name
  place_value = place_selector + " .meas_value"
  $(place_value).html(value)

  realtime_flash_after(place_selector)

@realtime_flash_after = (object) ->
  $(object).stop().animate(
    backgroundColor: "#ffaaaa"
  , 5).animate
    backgroundColor: "#FFFFFF"
  , 400