maintainer "Jörg Herzinger"
maintainer_email "joerg.herzinger@global2000.at, reset@global2000.at"
license "MIT"
description "Manage nginx sites"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

%w(ubuntu debian).each do |os|
  supports os
end
