include_recipe 'deploy'

node[:deploy].each do |application, deploy|

  ruby_block "stop mqtt.js application #{application}" do
    block do
      Chef::Log.info("stop node.js via: #{node[:deploy][application][:mqtt][:stop_command]}")
      Chef::Log.info(`#{node[:deploy][application][:mqtt][:stop_command]}`)
      $? == 0
    end
  end

  directory "#{deploy[:deploy_to]}" do
    recursive true
    action :delete

    only_if do
      ::File.exists?("#{deploy[:deploy_to]}")
    end
  end
end