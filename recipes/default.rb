package 'nginx'

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  not_if "/usr/sbin/nginx -t"
end

Nginx_locations.non_ssl = Hash.new()
Nginx_locations.ssl = Hash.new()
