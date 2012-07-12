nginx chef cookbook
===================

This cookbook is intended to easy the use of default nginx use cases with some simple definitions.

Examples
========

```ruby
nginx_server "my-url.com" do
  server_aliases ["my-url.net", "my-url.org"]
  enable_ssl true
  ssl_cert "/path/to/cert/blubb.crt"
  ssl_cert_key "/path/to/key/blubb.key"
end

nginx_location "my-url.com" do
  location "/squirrelmail"
  loc_type "static"
#  enable_ssl true
  allow_ssl_only true
  variables(
            :root => "/tmp/blubb",
            :indices => ["index.htm", "index.html"]
            )
end

nginx_location "my-url.com" do
  location "/foswiki"
  loc_type "proxy_pass"
  variables(
            :pass_url => "http://blubb"
            )
end

nginx_location "my-url.com" do
  loc_type "rewrite"
  location "~* ^.+\.(jpg|jpeg|gif)$"
  variables(
            :rewrite_url => "http://ihavenoideawheretogoto.com"
            )
end

nginx_location "my-url.com" do
  source "my_own_template.erb"
  cookbook "my_own_cookbook"
  location "somethingsomethingdarkside"
  variable(
	   :used_in_my_template => true
	   )
end
```

License
=======

See LICENSE file for details.