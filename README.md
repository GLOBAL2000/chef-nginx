nginx chef cookbook
===================

This cookbook is intended to easy the use of default nginx use cases with some simple definitions.

Server Definition
=================

Specify server name "default" to define a default server.

Valid Options here are:

* server_aliases: Array of Server names. Will be joined with the name var to give the nginx "server_name".
* enable_ssl: If true ssl will be enabled. In this case "ssl_cert" and "ssl_cert_key" are required.
* ssl_cert: Path to SSL Certificate on disk.
* ssl_cert_key: Path to SSL Certificate Key.
* config_options: A hash containing config options to be directly inserted into the the template.
* template_cookbook: If passed a custom template will be used from this cookbook.
* template_source: Name of the template that will be used.

Location Definition
===================

Valid Options here are:

* location: The Location part. See nginx documentation [1] for further details.
* enable_ssl: Have this location in ssl also.
* allow_ssl_only: Adds a rewrite rule to redirect all http request to https.
* loc_type: Location type. See section "Default Locations" for further details. Not needed if custom template is passed.
* config_options: A hash containing config options to be directly inserted into the the template.
* template_cookbook: If passed a custom template will be used from this cookbook.
* template_source: Name of the template that will be used.

Custom Templates
================

See existing templates for examples.

Default Locations
=================

* rewrite
* proxy_pass
* static

Examples
========

```ruby
nginx_server "my-url.com" do
  server_aliases ["my-url.net", "my-url.de"]
  enable_ssl true
  ssl_cert "/path/to/cert/blubb.crt"
  ssl_cert_key "/path/to/key/blubb.key"
  config_options <<EOF
bla blubb;
bli bläh;
EOF
end

nginx_location "my-url.com" do
  location "/squirrelmail"
  loc_type "static"
#  enable_ssl true
  allow_ssl_only true
  config_options(
            :root => "/tmp/blubb",
            )
end

nginx_location "my-url.com" do
  location "/wiki"
  loc_type "proxy_pass"
  config_options(
                 :pass_url => "http://blubb",
                 :custom_config => <<EOF
my custom;
location settings here;
EOF
                 )
end

nginx_location "my-url.com" do
  loc_type "rewrite"
  location "~* ^.+\.(jpg|jpeg|gif)$"
  variables(
            :rewrite_url => "http://ihavenoideawheretogoto.com",
            :custom_config => "just_one line here;"
            )
end

nginx_location "my-url.com" do
  source "my_own_template.erb"
  cookbook "my_own_cookbook"
  location "somethingsomethingdarkside"
  config_options(
       :used_in_my_template => true
       )
end
```

License
=======

See LICENSE file for details.

[1] http://wiki.nginx.org/HttpCoreModule#location
