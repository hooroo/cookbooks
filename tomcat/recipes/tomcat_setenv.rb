# Cookbook Name:: tomcat
# Recipe:: tomcat_setenv
# Description: set environment variables for Tomcat
#
# Copyright 2014, Hooroo

node[:deploy].each do |application, deploy|

  if deploy[:application_type] != 'java'
    Chef::Log.debug("Skipping hooroo::tomcat_setenv setup as this instance is not a java app server")
    next
  end

  execute "mkdir -p /var/lib/tomcat7/bin"

  tomcat_setenv = "/var/lib/tomcat7/bin/setenv.sh"

  template tomcat_setenv do
    owner root
    group tomcat7
    mode 00644
    source "setenv.sh.erb"
    variables({
      :jetstar_password => "#{node[:hooroo][:rails_http_basic_auth_users][:jetstar]}",
      :redis_host => "#{node[:rails_sidekiq][:redis_host]}",
      :redis_port => node[:rails_sidekiq][:redis_port]
    })
  end
end
