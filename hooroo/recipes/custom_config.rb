# Cookbook Name:: hooroo
# Recipe:: custom_config
#
# Copyright 2014, Hooroo

if node[:custom_config]
  access_key_id     = node[:custom_config][:access_key_id]
  secret_access_key = node[:custom_config][:secret_access_key]
  chef_json_url     = node[:custom_config][:chef_json_url]

  _, s3_bucket, chef_json_file = URI.parse().path.match(/^\/([^\/]+)\/(.+)$/).to_a

  s3 = AWS::S3.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
  bucket = s3.buckets[s3_bucket]

  node[:custom_config][:json] = bucket.objects[chef_json_file].read

  Chef::Log.debug "node[:custom_config][:json]=#{node[:custom_config][:json]}"
end
