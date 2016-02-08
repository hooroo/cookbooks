#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

  default['postgresql']['version'] = "9.4"
  default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['server']['service_name'] = "postgresql"

  default['postgresql']['client']['packages'] = %w{postgresql-client-9.4 libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql-9.2}
  default['postgresql']['contrib']['packages'] = %w{postgresql-contrib-9.2}

  default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  default['postgresql']['config']['listen_addresses'] = '*'
  default['postgresql']['config']['port'] = 5432
  default['postgresql']['config']['max_connections'] = 500
  default['postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql'
  default['postgresql']['config']['max_fsm_pages'] = 153600 if node['postgresql']['version'].to_f < 8.4
  default['postgresql']['config']['log_line_prefix'] = '%t '
  default['postgresql']['config']['datestyle'] = 'iso, mdy'
  default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
  default['postgresql']['config']['ssl'] = false

default['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '10.0.0.1/16', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

default['postgresql']['password'] = Hash.new
default['postgresql']['password']['postgres'] = "password"

default['postgresql']['enable_pitti_ppa'] = true 
default['postgresql']['enable_pgdg_yum'] = false
