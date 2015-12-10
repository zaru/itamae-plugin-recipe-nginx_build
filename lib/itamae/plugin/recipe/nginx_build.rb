require "itamae/plugin/recipe/nginx_build/version"

nginx_build_platform = "linux"
nginx_build_platform = node[:nginx_build][:platform] if node[:nginx_build] && node[:nginx_build][:platform]

nginx_build_version = "0.6.4"
nginx_build_version = node[:nginx_build][:version] if node[:nginx_build] && node[:nginx_build][:version]

nginx_build_bin = "/usr/local/bin/"
nginx_build_bin = node[:nginx_build][:bin] if node[:nginx_build] && node[:nginx_build][:bin]

%w(pcre pcre-devel).each do |pkg|
  package pkg
end

execute "nginx-build install" do
  nginx_build = <<"EOS"
cd /tmp && \
wget https://github.com/cubicdaiya/nginx-build/releases/download/v#{nginx_build_version}/nginx-build-#{nginx_build_platform}-amd64-#{nginx_build_version}.tar.gz && \
tar zxvf nginx-build-#{nginx_build_platform}-amd64-#{nginx_build_version}.tar.gz && \
rm -rf nginx-build-#{nginx_build_platform}-amd64-#{nginx_build_version}.tar.gz
mv nginx-build #{nginx_build_bin}
EOS
  command nginx_build
  not_if "test -e #{nginx_build_bin}nginx-build"
end