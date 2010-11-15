# Module mixing code for simulation mode
module HomeIoMeasElementOffline

  # random seed used in simulation, sine-like speed
  OFFLINE_MAX_SEED = 1000
  OFFLINE_SPEED = Math::PI / 5.0

  # Create raw value retrieved in simulation
  def offline_create_raw
    # timelike axis
    time = ( (Time.now.to_f % @offline[:seed].to_f) + Time.now.to_f ) * OFFLINE_SPEED
    # value
    value = ( Math::sin( time ) + 1.0 ) * 0.5
    value = @offline[:range] * value + @offline[:min_value]
    # return to raw
    raw_value = (value / @transformation[:scaler] ).to_i - @transformation[:offset]

    return raw_value
  end


end
