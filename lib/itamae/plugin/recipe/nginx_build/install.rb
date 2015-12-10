nginx_user = "nginx"
nginx_user = node[:nginx_build][:user] if node[:nginx_build] && node[:nginx_build][:user]

nginx_group = "nginx"
nginx_group = node[:nginx_build][:group] if node[:nginx_build] && node[:nginx_build][:group]

nginx_sbin = "nginx"
nginx_sbin = node[:nginx_build][:sbin] if node[:nginx_build] && node[:nginx_build][:sbin]

nginx_conf = "nginx"
nginx_conf = node[:nginx_build][:conf] if node[:nginx_build] && node[:nginx_build][:conf]

nginx_pid = "nginx"
nginx_pid = node[:nginx_build][:pid] if node[:nginx_build] && node[:nginx_build][:pid]

nginx_modules = %w(http_ssl_module)
nginx_modules = node[:nginx_build][:modules] if node[:nginx_build] && node[:nginx_build][:modules]

configure_path = '/usr/local/nginx_build/configure.sh'
configure_path = node[:nginx_build][:configure_path] if node[:nginx_build] && node[:nginx_build][:configure_path]

if configure_path =~ /^(.+)\/([^\/]+)$/
  directory $1

  configure = <<-EOS
#!/bin/sh

./configure \
  --user=#{nginx_user} \
  --group=#{nginx_group} \
  --sbin-path=#{nginx_sbin} \
  --conf-path=#{nginx_conf} \
  --pid-path=#{nginx_pid} \
EOS

  nginx_modules.each do |m|
    configure += " --with-#{m} "
  end

  execute 'add configure script' do
    command "echo '#{configure}' >> #{configure_path}"
    not_if "test -e #{configure_path}"
  end

end