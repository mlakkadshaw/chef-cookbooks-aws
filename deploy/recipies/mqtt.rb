include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_nodejs do
    deploy_data deploy
    app application
  end

  application_environment_file do
    user deploy[:user]
    group deploy[:group]
    path ::File.join(deploy[:deploy_to], "shared")
    environment_variables deploy[:environment_variables]
  end

  ruby_block "restart mqtt application #{application}" do
    block do
      Chef::Log.info("restart mqtt via: #{node[:deploy][application][:mqtt][:restart_command]}")
      Chef::Log.info(`#{node[:deploy][application][:mqtt][:restart_command]}`)
      $? == 0
    end
  end
end