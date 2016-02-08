include_recipe 'apt'

apt_repository 'pitti-postgresql-ppa' do
  uri 'http://ppa.launchpad.net/pitti/postgresql/ubuntu'
  distribution node['lsb']['codename']
  components %w(main)
  keyserver 'keyserver.ubuntu.com'
  key '8683D8A2'
  action :add
end

apt_repository 'postgresql' do
  uri 'http://apt.postgresql.org/pub/repos/apt/'
  distribution 'precise-pgdg'
  components %w(main)
  key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
  action :add
end
