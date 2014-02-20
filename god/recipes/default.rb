gem_package 'god' do
  version '0.13.3'
end

template 'god.conf' do
  path '/etc/god/god.conf'
  source 'god.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
end
