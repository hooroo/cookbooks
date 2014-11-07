# Cookbook Name:: hooroo
# Recipe:: monit_sqs_worker
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
  unless deploy[:sqs_worker]
    Chef::Log.debug("Skipping deploy::monit_sqs_worker application #{application} as it does not have SQS Worker as a requirement")
    next
  end

  sqs_worker_script = "#{deploy[:deploy_to]}/shared/scripts/sqs_worker"

  template sqs_worker_script do
    owner deploy[:user]
    group deploy[:group]
    mode 0755
    source "sqs_worker.erb"
    variables({
      :deploy    => deploy
    })
    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/scripts/")
    end
  end

  pid_file = "#{deploy[:deploy_to]}/current/tmp/pids/sqs_worker.pid"

  template "/etc/monit/conf.d/sqs_worker_#{application}.monitrc" do
    owner 'root'
    group 'root'
    mode 0644
    source "sqs_worker_monitrc.conf.erb"
    variables({
      :service       => 'sqs_worker',
      :application   => application,
      :user          => deploy[:user],
      :pid_file      => pid_file,
      :start_program => "#{sqs_worker_script} start",
      :stop_program  => "#{sqs_worker_script} stop"
    })
    notifies :restart, "service[monit]", :immediately
  end

  # This will fail if the guard condition on template sqs_worker_script kicked in
  # seems likely on the config run
  # that's okay - it'll come good on the deploy run
  execute "restart sqs_worker_#{application}" do
    cwd deploy[:current_path]
    command "/usr/bin/monit restart sqs_worker_#{application}"
    action :run
  end
end
