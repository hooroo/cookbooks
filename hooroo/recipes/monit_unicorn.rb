# Cookbook Name:: hooroo
# Recipe:: locale
#
# Copyright 2013, Hooroo

include_recipe 'deploy::default'
include_recipe 'opsworks_agent_monit::service'

package "monit" do
  action :install
end

node[:deploy].each do |application, deploy|
  unless File.exist?(deploy[:deploy_to])
    Chef::Log.debug("Skipping hooroo::monit_unicorn setup as this instance is not an app server")
    next
  end

  unicorn_script = "/usr/bin/env PATH=/usr/local/bin:$PATH #{deploy[:deploy_to]}/shared/scripts/unicorn"
  pid_file = "#{deploy[:deploy_to]}/current/tmp/pids/unicorn.pid"

  template "/etc/monit/conf.d/unicorn_#{application}.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "unicorn_monitrc.conf.erb"
    variables({
      :service       => 'unicorn',
      :application   => application,
      :user          => deploy[:user],
      :group         => deploy[:group],
      :pid_file      => pid_file,
      :start_program => "#{unicorn_script} start",
      :stop_program  => "#{unicorn_script} stop"
    })
    notifies :reload, "service[monit]", :immediately
  end
end
