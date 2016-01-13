  # mqtt
  node[:deploy].each do |application, deploy|
  	default[:deploy][application][:mqtt][:restart_command] = "npm install -g forever; forever stopall; forever start #{default[:deploy][application][:deploy_to]}/current/index.js"
  	default[:deploy][application][:mqtt][:stop_command] = "forever stopall"
  end