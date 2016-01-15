  # mqtt
  node[:deploy].each do |application, deploy|
  	if deploy[application] == 'mqtt'
  		normal[:deploy][application][:mqtt][:restart_command] = "npm install -g forever; forever stopall; forever start #{normal[:deploy][application][:deploy_to]}/current/index.js"
  		normal[:deploy][application][:mqtt][:stop_command] = "forever stopall"
  	end
  end