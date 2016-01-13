  # mqtt
  default[:deploy][application][:mqtt][:restart_command] = "forever stopall; forever start #{default[:deploy][application][:deploy_to}/current/index.js"
  default[:deploy][application][:mqtt][:stop_command] = "forever stopall"