define :nginx_location,
  :location => nil,
  :enable_ssl => false,
  :allow_ssl_only => false,
  :template_cookbook => nil,
  :template_source => nil,
  :loc_type => nil,
  :variables => nil do

  unless params[:location]
    raise "Location needs to be given"
  end

  unless params[:loc_type] || (params[:template_cookbook] && params[:template_source])
    raise "Need either type or template_cookbook and template_source defined"
  end

  server_name = params[:name]
  loc = params[:location]
  tmp_dir = "#{node["nginx"]["config_tmp"]}/#{server_name}"
  template_vars = params[:variables] || Hash.new()
  template_vars[:location] = params[:location]
  dossl = ( params[:enable_ssl] || params[:allow_ssl_only] )

  unique_id = loc.sum()
  non_ssl_number = 1 + Nginx_locations.non_ssl.length
  ssl_number = 51 + Nginx_locations.ssl.length if dossl

  Nginx_locations.non_ssl[unique_id] = non_ssl_number
  Nginx_locations.ssl[unique_id] = ssl_number if dossl

  # SSL ONLY: rewrite http to https
  if !params[:allow_ssl_only]
    template "#{tmp_dir}/#{non_ssl_number.to_s.rjust(2,'0')}_#{unique_id}" do
      cookbook params[:template_cookbook] if params[:template_cookbook]
      source "#{params[:loc_type]}.erb" || params[:template_cookbook]
      variables template_vars
      notifies :create, "ruby_block[nginx_site_#{server_name}]"
    end
  else
    template_vars[:rewrite_url] = "https://#{server_name}"
    template "#{tmp_dir}/#{non_ssl_number.to_s.rjust(2,'0')}_#{unique_id}" do
      source "rewrite.erb"
      variables template_vars
      notifies :create, "ruby_block[nginx_site_#{server_name}]"
    end
  end

  template "#{tmp_dir}/#{ssl_number.to_s.rjust(2,'0')}_#{unique_id}" do
    cookbook params[:template_cookbook] if params[:template_cookbook]
    source "#{params[:loc_type]}.erb" || params[:template_cookbook]
    variables template_vars
    notifies :create, "ruby_block[nginx_site_#{server_name}]"
  end if dossl
  
end
