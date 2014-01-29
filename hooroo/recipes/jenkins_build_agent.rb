# Cookbook Name:: hooroo
# Recipe:: buildagent
#
# Copyright 2013, Hooroo

service "jenkins" do
  supports [ :stop, :start, :restart, :status ]
  status_command "test -f #{node[:jenkins_build_agent][:pid_file]} && kill -0 `cat #{node[:jenkins_build_agent][:pid_file]}`"
  action :nothing
end

# apt packages
#
%w{
  xvfb
  firefox
  postgresql-9.2
  postgresql-contrib-9.2
}.each do |package_name|
  package package_name do
    action :install
  end
end

# Gems
#
gem_package "bundler" do
  action :install
end

# SSH keys
#
directory "#{node[:jenkins_build_agent][:base_dir]}/.ssh" do
  owner "jenkins"
  group "jenkins"
  mode 00700
end

if node[:toolbelt]
  template "#{node[:jenkins_build_agent][:base_dir]}/.toolbelt.yml" do
    source "toolbelt.yml.erb"
    owner "jenkins"
    group "jenkins"
    mode 00600
    variables(
      :aws_access_key_id      => node[:toolbelt][:aws_access_key_id],
      :aws_secret_access_key  => node[:toolbelt][:aws_secret_access_key]
    )
  end
end

cookbook_file "jenkins_ssh_config" do
  owner "jenkins"
  group "jenkins"
  mode 00600
  path "#{node[:jenkins_build_agent][:base_dir]}/.ssh/config"
end

# PostgreSQL roles
#
if node['jenkins'] && node['jenkins']['database'] && node['jenkins']['database']['roles']

  node['jenkins']['database']['roles'].each do |role|

    username = role['username']
    options = role['options']

    bash "Create PostgreSQL #{username} role" do
      user "postgres"
      cwd "/tmp"
      code <<-EOH
        psql postgres -c "CREATE ROLE #{username} WITH #{options}"
      EOH

      only_if %Q{ test `psql postgres -t --no-align -c "SELECT 1 FROM pg_roles WHERE rolname='#{username}'"`x != "1x" }, :user => 'postgres'
    end
  end
end

# PostgreSQL databases
#
if node['jenkins'] && node['jenkins']['database'] && node['jenkins']['database']['databases']

  node['jenkins']['database']['databases'].each do |database|

    name = database['name']
    owner = database['owner']

    bash "Create PostgreSQL #{name} database" do
      user "postgres"
      cwd "/tmp"
      code <<-EOH
        psql postgres -c "CREATE DATABASE #{name} OWNER #{owner}"
      EOH

      only_if %Q{ test `psql postgres -t --no-align -c "SELECT 1 FROM pg_database WHERE datname='#{name}'"`x != "1x" }, :user => 'postgres'
    end
  end
end

# PhantomJS
#
remote_file "/tmp/#{node[:jenkins_build_agent][:phantomjs][:download_filename]}" do
  owner "root"
  group "root"
  mode 00644
  source node[:jenkins_build_agent][:phantomjs][:download_url]
  checksum node[:jenkins_build_agent][:phantomjs][:download_md5]
  not_if { File.exist?(node[:jenkins_build_agent][:phantomjs][:install_path]) }
end

bash "unpack PhantomJS" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar xjvf /tmp/#{node[:jenkins_build_agent][:phantomjs][:download_filename]}
    mv #{node[:jenkins_build_agent][:phantomjs][:temporary_path]} #{node[:jenkins_build_agent][:phantomjs][:install_path]}
    ln -fs #{node[:jenkins_build_agent][:phantomjs][:install_path]} /opt/phantomjs
    ln -fs #{node[:jenkins_build_agent][:phantomjs][:path]}/bin/phantomjs /usr/local/bin/phantomjs
  EOH
  not_if { File.exist?(node[:jenkins_build_agent][:phantomjs][:install_path]) }
end

# Ensure shell is bash
#
user "jenkins" do
  shell "/bin/bash"
  action :modify
end

directory node[:jenkins_build_agent][:backup_path] do
  owner "root"
  group "root"
  mode 02777
  only_if { File.exist?(node[:jenkins_build_agent][:data_path]) }
end

directory node[:jenkins_build_agent][:workspace_path] do
  owner "jenkins"
  group "jenkins"
  mode 00700
  only_if { File.exist?(node[:jenkins_build_agent][:data_path]) }
end

# Move jenkins workspace directory is on /mnt/jenkins-workspace (EBS)
#
bash "move jenkins workspace directory to #{node[:jenkins_build_agent][:workspace_path]} (EBS)" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    mv #{node[:jenkins_build_agent][:original_workspace_path]} #{node[:jenkins_build_agent][:workspace_path]}
  EOH
  notifies :stop, "service[jenkins]", :immediately
  notifies :start, "service[jenkins]"
  only_if { File.directory?(node[:jenkins_build_agent][:original_workspace_path]) && !File.symlink?(node[:jenkins_build_agent][:original_workspace_path]) }
end

# Ensure jenkins workspace directory is on /mnt/jenkins-workspace (EBS)
#
bash "ensure jenkins workspace directory points to #{node[:jenkins_build_agent][:workspace_path]} (EBS)" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    ln -sf #{node[:jenkins_build_agent][:workspace_path]} #{node[:jenkins_build_agent][:original_workspace_path]}
  EOH
  notifies :stop, "service[jenkins]", :immediately
  notifies :start, "service[jenkins]"
  not_if { File.symlink?(node[:jenkins_build_agent][:original_workspace_path]) }
end

bash "sudojenkins" do
	user "root"
	cwd "/tmp"
	ignore_failure true
	code <<-EOH
		gpasswd -a jenkins admin
	EOH
end
