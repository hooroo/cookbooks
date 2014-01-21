# Cookbook Name:: hooroo
# Recipe:: nginx
#
# Copyright 2013, Hooroo

include_recipe 'nginx'

node.override['nginx']['event'] = 'epoll'
node.override['nginx']['worker_connections'] = 10240
node.override['nginx']['keepalive_timeout'] = 30
