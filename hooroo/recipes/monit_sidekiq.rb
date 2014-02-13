# Cookbook Name:: hooroo
# Recipe:: monit_sidekiq
#
# Copyright 2013, Hooroo

include_recipe 'hooroo::wait_for_www_mount'
include_recipe 'deploy::default'
include_recipe 'opsworks_agent_monit::service'

package "monit" do
  action :install
end

node[:deploy].each do |application, deploy|
  unless File.exist?(deploy[:deploy_to])
    Chef::Log.debug("Skipping hooroo::monit_sidekiq setup as this instance is not an app server")
    next
  end

  sidekiq_script = "#{deploy[:deploy_to]}/shared/scripts/sidekiq"

  template sidekiq_script do
    owner deploy[:user]
    group deploy[:group]
    mode 0755
    source "sidekiq.erb"
    variables({
      :deploy => deploy
    })
    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/scripts/")
    end
  end

  sidekiq_command = "#{deploy[:deploy_to]}/shared/scripts/sidekiq"
  pid_file = "#{deploy[:deploy_to]}/current/tmp/pids/sidekiq.pid"

  template "/etc/monit/conf.d/sidekiq_#{application}.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "sidekiq_monitrc.conf.erb"
    variables({
      :service       => 'sidekiq',
      :application   => application,
      :user          => deploy[:user],
      :pid_file      => pid_file,
      :start_program => "#{sidekiq_command} start",
      :stop_program  => "#{sidekiq_command} stop"
    })
    notifies :reload, "service[monit]", :immediately
  end

  execute "restart sidekiq_#{application}" do
    cwd deploy[:current_path]
    command "/usr/bin/monit restart sidekiq_#{application}"
    action :run
  end
end
