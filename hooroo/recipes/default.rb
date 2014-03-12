# Cookbook Name:: hooroo
# Recipe:: default
#
# Copyright 2013, Hooroo

include_recipe 'hooroo::custom_config'
include_recipe 'hooroo::ssh_keys'
include_recipe 'hooroo::locale'
include_recipe 'hooroo::packages'
include_recipe 'hooroo::users'
include_recipe 'hooroo::wait_for_www_mount'
include_recipe 'hooroo::deploy_prepare'
include_recipe 'splunk'
