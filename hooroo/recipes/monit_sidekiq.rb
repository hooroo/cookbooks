# Cookbook Name:: hooroo
# Recipe:: monit_sidekiq
#
# Copyright 2013, Hooroo

include_recipe 'hooroo::wait_for_www_mount'
include_recipe 'hooroo::deploy_prepare'
include_recipe 'deploy::default'
include_recipe 'opsworks_agent_monit::service'

package "monit" do
  action :install
end

node[:deploy].each do |application, deploy|
  sidekiq_script = "#{deploy[:deploy_to]}/shared/scripts/sidekiq"

  template sidekiq_script do
    owner deploy[:user]
    group deploy[:group]
    mode 0755
    source "sidekiq.erb"
    variables({
      :deploy    => deploy,
      :redis_url => "redis://#{node[:rails_sidekiq][:redis_server]}:#{node[:rails_sidekiq][:redis_port]}"
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
    notifies :restart, "service[monit]", :immediately
  end

  # This will fail if the guard condition on template sidekiq_script kicked in
  # seems likely on the config run
  # that's okay - it'll come good on the deploy run
  execute "restart sidekiq_#{application}" do
    cwd deploy[:current_path]
    command "/usr/bin/monit restart sidekiq_#{application}"
    action :run
  end
end
