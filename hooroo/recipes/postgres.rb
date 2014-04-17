# Cookbook Name:: hooroo
# Recipe:: postgres
#
# Copyright 2013, Hooroo

include_recipe 'postgresql::server'

directory "/var/lib/postgresql/#{node['postgresql']['version']}/main/archives" do
  owner "postgres"
  group "postgres"
  mode 00700
  action :create
end

template "#{node['postgresql']['dir']}/recovery.conf" do
  source "recovery.conf.erb"
  owner "root"
  group "root"
  mode 00644
  variables ({
    :restore_command => "cp /var/lib/postgresql/#{node['postgresql']['version']}/main/archives/%f %p"
  })
end

link "#{node[:postgresql][:config][:data_directory]}/recovery.conf" do
  to "#{node[:postgresql][:dir]}/recovery.conf"
  not_if do
    # don't setup replication on a database master
    node[:hooroo] && node[:hooroo][:postgres] && node[:hooroo][:postgres][:database_master] == instance_name
  end
  only_if "test -d #{node[:postgresql][:config][:data_directory]}"
end

postgres_pg_hba = [
  { :type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident' },
  { :type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident' },
  { :type => 'local', :db => 'replication', :user => 'postgres', :addr => nil, :method => 'trust' },
  { :type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5' },
  { :type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5' },
  { :type => 'host', :db => 'all', :user => 'all', :addr => '10.0.0.1/16', :method => 'md5' },
  { :type => 'host', :db => 'all', :user => 'all', :addr => '10.0.0.0/8', :method => 'md5' }
]

node[:opsworks][:layers].each do |layer_name, layer_config|
  layer_config[:instances].each do |instance_name, instance_config|
    if instance_name.match(/-db.+/)
      postgres_pg_hba << { :type => 'host', :db => 'replication', :user => 'replicator', :addr => instance_name, :method => 'trust' }
    end
  end
end

node.override['postgresql']['pg_hba'] = postgres_pg_hba

node.override['postgresql']['config']['hot_standby'] = 'on'
node.override['postgresql']['config']['wal_level'] = 'hot_standby'
node.override['postgresql']['config']['max_wal_senders'] = 5
node.override['postgresql']['config']['wal_keep_segments'] = 32
node.override['postgresql']['config']['archive_mode'] = 'on'
node.override['postgresql']['config']['archive_command'] = "cp %p /var/lib/postgresql/#{node['postgresql']['version']}/main/archives/%f"

database_details = node[:hooroo].fetch(:postgres, false)

template "/etc/sysctl.d/99-hooroo-postgresql-shm.conf" do
  source "postgresql_shm_sysctl.erb"
  owner "root"
  group "root"
  mode 00644
  variables ({
    :shmmax => node[:postgresql][:config][:shmmax],
    :shmall => node[:postgresql][:config][:shmall]
  })
end

node[:hooroo][:postgres][:users].each do |user|

  db_username = user[:username]
  db_password = user[:password]
  db_options = user[:options]

  bash "Create PostgreSQL #{db_username} role" do
    user "postgres"
    cwd "/tmp"
    code <<-EOH
      psql postgres -c "CREATE ROLE \\"#{db_username}\\" WITH PASSWORD '#{db_password}' #{db_options}"
    EOH

    only_if %Q{ test `psql postgres -t --no-align -c "SELECT 1 FROM pg_roles WHERE rolname='#{db_username}'"`x != "1x" }, :user => 'postgres'
  end
end

node[:deploy].each do |application, x|

  database_details = node[:deploy][application].fetch(:database, false)

  if database_details

    db_database = database_details[:database]
    db_username = database_details[:username]
    db_password = database_details[:password]

    bash "Create PostgreSQL #{db_username} role" do
      user "postgres"
      cwd "/tmp"
      code <<-EOH
        psql postgres -c "CREATE ROLE \\"#{db_username}\\" WITH PASSWORD '#{db_password}' LOGIN"
      EOH

      only_if %Q{ test `psql postgres -t --no-align -c "SELECT 1 FROM pg_roles WHERE rolname='#{db_username}'"`x != "1x" }, :user => 'postgres'
    end

    bash "Create PostgreSQL databases" do
      user "postgres"
      cwd "/tmp"
      code <<-EOH
        psql postgres -c "CREATE DATABASE #{db_database} OWNER #{db_username}"
      EOH

      only_if %Q{ test `psql postgres -t --no-align -c "SELECT 1 FROM pg_database WHERE datname='#{db_database}'"`x != "1x" }, :user => 'postgres'
    end
  end
end
