include_recipe 'deploy'

PACKAGE_BASENAME = "opsworks-nodejs"
LECAGY_PACKAGES = []

  pm_helper = OpsWorks::PackageManagerHelper.new(node)
  current_package_info = pm_helper.summary(PACKAGE_BASENAME)

  if current_package_info.version && current_package_info.version.start_with?(node[:opsworks_nodejs][:version])
    Chef::Log.info("Userspace NodeJS version is up-to-date (#{node[:opsworks_nodejs][:version]})")
  else

    packages_to_remove = pm_helper.installed_packages.select do |pkg, version|
      pkg.include?(PACKAGE_BASENAME) || LECAGY_PACKAGES.include?(pkg)
    end

    packages_to_remove.each do |pkg, version|
      package "Remove outdated package #{pkg}" do
        package_name pkg
        action :remove
      end
    end

    log "downloading" do
      message "Download and install NodeJS version #{node[:opsworks_nodejs][:full_version]} patch #{node[:opsworks_nodejs][:patch]} release #{node[:opsworks_nodejs][:pkgrelease]}"
      level :info

      action :nothing
    end

    opsworks_commons_assets_installer "Install user space OpsWorks NodeJS package" do
      asset PACKAGE_BASENAME
      version node[:opsworks_nodejs][:version]
      release node[:opsworks_nodejs][:pkgrelease]

      notifies :write, "log[downloading]", :immediately
      action :install
    end
  end
  
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'nodejs'
    Chef::Log.debug("Skipping deploy::nodejs for application #{application} as it is not a node.js app")
    next
  end

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