define :nginx_server,
  :server_aliases => nil,
  :enable_ssl => false,
  :ssl_cert => nil,
  :ssl_cert_key => nil,
  :config_options => nil,
  :template_cookbook => nil,
  :template_source => nil do

  if params[:enable_ssl] && (params[:ssl_cert].nil? || params[:ssl_cert_key].nil?)
    raise "ssl_cert and ssl_cert_key need to be specified if ssl is enabled."
  end

  server_name = params[:name]
  tmp_dir = "#{node["nginx"]["config_tmp"]}/#{server_name}"

  template_vars = Hash.new()
  %w(ssl_cert ssl_cert_key name server_aliases config_options).each do |k|
    template_vars[k.to_sym] = params[k.to_sym]
  end

  directory "#{tmp_dir}" do
    action :create
    recursive true
  end

  template "#{tmp_dir}/00" do
    cookbook params[:template_cookbook] ? params[:template_cookbook] : "nginx"
    source params[:template_source] ? params[:template_source] : "00_header.erb"
    variables template_vars
    notifies :create, "ruby_block[nginx_site_#{server_name}]"
  end

  template "#{tmp_dir}/50" do
    cookbook params[:template_cookbook] ? params[:template_cookbook] : "nginx"
    source params[:template_source] ? params[:template_source] : "50_header_ssl.erb"
    variables template_vars
    notifies :create, "ruby_block[nginx_site_#{server_name}]"
  end if params[:enable_ssl]
  
  ruby_block "nginx_site_#{server_name}" do
    notifies :reload, "service[nginx]"
    action :nothing
    block do
      outFile = File.new("#{node["nginx"]["sites_dir"]}/#{server_name}", "w+")
      [0..Nginx_locations.non_ssl[server_name.intern], 50..Nginx_locations.ssl[server_name.intern]].each do |serv|
        outFile << "server {\n"

        files = serv.to_a.sort
        files.map! { |e| e.to_s.rjust(2,"0") }
        files.map! { |e| "#{tmp_dir}/#{e}" }
        files.each do |inFile|
          f = File.open(inFile, "r")  
          f.each_line { |line| outFile << line }
          f.close
          outFile << "\n"
        end
        outFile << "}\n"
      end
    end
  end
end
