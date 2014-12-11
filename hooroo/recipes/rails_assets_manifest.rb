# Cookbook Name:: hooroo
# Recipe:: rails_assets_manifest
#
# Copyright 2014, Hooroo

include_recipe 'aws'
include_recipe 'hooroo::wait_for_www_mount'
include_recipe 'hooroo::deploy_prepare'
include_recipe 'deploy::default'

node[:deploy].each do |application, deploy|

  manifest_filename = "assets/manifest-#{deploy[:scm][:revision]}.json"

  aws_s3_file "#{deploy[:deploy_to]}/public/#{manifest_filename}" do
    bucket node[:hooroo][:rails_assets_manifest][:bucket]
    remote_path manifest_filename
    aws_access_key_id     node[:hooroo][:rails_assets_manifest][:aws_access_key_id]
    aws_secret_access_key node[:hooroo][:rails_assets_manifest][:aws_secret_access_key]
  end

end
