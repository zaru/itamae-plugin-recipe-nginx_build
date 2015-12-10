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

modules3rd_path = '/usr/local/nginx_build/modules3rd.ini'
modules3rd_path = node[:nginx_build][:modules3rd_path] if node[:nginx_build] && node[:nginx_build][:modules3rd_path]

nginx_modules3rds = []
nginx_modules3rds = node[:nginx_build][:modules3rds] if node[:nginx_build] && node[:nginx_build][:modules3rds]

if configure_path =~ /^(.+)\/([^\/]+)$/
  directory $1

  template configure_path do
    source "./templates/configure.sh.erb"
    variables({
                  "nginx_user"    => nginx_user,
                  "nginx_group"   => nginx_group,
                  "nginx_sbin"    => nginx_sbin,
                  "nginx_conf"    => nginx_conf,
                  "nginx_pid"     => nginx_pid,
                  "nginx_modules" => nginx_modules
              })
  end

end

if modules3rd_path =~ /^(.+)\/([^\/]+)$/
  directory $1

  template modules3rd_path do
    source "./templates/modules3rd.ini.erb"
    variables({
                  "nginx_modules3rds" => nginx_modules3rds
              })
  end

end