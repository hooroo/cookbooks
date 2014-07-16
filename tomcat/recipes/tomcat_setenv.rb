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

  template "/var/lib/tomcat7/bin/setenv.sh" do
    owner "root"
    group "tomcat7"
    mode 00644
    source "tomcat_setenv.sh.erb"
    variables({
      :jetstar_password => "#{node[:hooroo][:rails_http_basic_auth_users][:jetstar]}",
      :redis_host => "#{node[:rails_sidekiq][:redis_server]}",
      :redis_port => node[:rails_sidekiq][:redis_port]
    })
  end
end
