define :nginx_server,
  :server_aliases => nil,
  :enable_ssl => false,
  :ssl_cert => nil,
  :ssl_cert_key => nil,
  :template_cookbook => nil,
  :template_source => nil do

  if (params[:enable_ssl] || params[:allow_ssl_only]) && (params[:ssl_cert].nil? || params[:ssl_cert_key].nil?)
    raise "ssl_cert and ssl_cert_key need to be specified if ssl is enabled."
  end

  server_name = params[:name]
  server_aliases = Array( params[:server_aliases] )
  tmp_dir = "#{node["nginx"]["config_tmp"]}/#{server_name}"

  directory "#{tmp_dir}" do
    action :create
    recursive true
  end

  template "#{tmp_dir}/00_header" do
    cookbook params[:template_cookbook] if params[:template_cookbook]
    source params[:template_source] if params[:template_source]
    variables(
              :server_name => server_name,
              :server_aliases => server_aliases
              )
  end

  template "#{tmp_dir}/50_header_ssl" do
    cookbook params[:template_cookbook] if params[:template_cookbook]
    source params[:template_source] if params[:template_source]
    variables(
              :server_name => server_name,
              :server_aliases => server_aliases,
              :ssl_cert => params[:ssl_cert],
              :ssl_cert_key => params[:ssl_cert_key]
              )
  end if params[:enable_ssl]
  
  ruby_block "nginx_site_#{server_name}" do
    notifies :reload, "service[nginx]"
    action :nothing
    block do
      outFile = File.new("#{node["nginx"]["sites_dir"]}/#{server_name}", "w+")
      ["0-4", "5-9"].each do |range|
        files = Dir.glob("#{tmp_dir}/[#{range}][0-9]_*").sort
        outFile << "server {\n"
        files.each do |inFile|
          # Get only those which are currently in recipes. Old ones are not taken
          check = inFile.scan(/(\d\d)_(.*)$/).flatten
          next unless ( ( Nginx_locations.non_ssl[check[1].to_i].to_i == check[0].to_i ) || ( Nginx_locations.ssl[check[1].to_i].to_i == check[0].to_i ) || check[1] == "header" || check[1] == "header_ssl" )

          f = File.open(inFile, "r")  
          f.each_line { |line| outFile << line }
          f.close
        end
        outFile << "}\n"
      end
    end
  end
end
