  # mqtt
  node[:deploy].each do |application, deploy|
  	node[:deploy][application][:mqtt][:restart_command] = "npm install -g forever; forever stopall; forever start #{default[:deploy][application][:deploy_to]}/current/index.js"
  	node[:deploy][application][:mqtt][:stop_command] = "forever stopall"
  end