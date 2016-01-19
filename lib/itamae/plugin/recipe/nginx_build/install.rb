nginx_build_bin = "/usr/local/bin/"
nginx_build_bin = node[:nginx_build][:bin] if node[:nginx_build] && node[:nginx_build][:bin]

nginx_user = "nginx"
nginx_user = node[:nginx_build][:nginx_user] if node[:nginx_build] && node[:nginx_build][:nginx_user]

nginx_group = "nginx"
nginx_group = node[:nginx_build][:nginx_group] if node[:nginx_build] && node[:nginx_build][:nginx_group]

nginx_sbin = "/usr/sbin/nginx"
nginx_sbin = node[:nginx_build][:nginx_sbin] if node[:nginx_build] && node[:nginx_build][:nginx_sbin]

nginx_conf = "/etc/nginx/nginx.conf"
nginx_conf = node[:nginx_build][:nginx_conf] if node[:nginx_build] && node[:nginx_build][:nginx_conf]

nginx_pid = "/var/run/nginx.pid"
nginx_pid = node[:nginx_build][:nginx_pid] if node[:nginx_build] && node[:nginx_build][:nginx_pid]

nginx_modules = %w(http_ssl_module)
nginx_modules = node[:nginx_build][:modules] if node[:nginx_build] && node[:nginx_build][:modules]

configure_path = '/usr/local/nginx_build/configure.sh'
configure_path = node[:nginx_build][:configure_path] if node[:nginx_build] && node[:nginx_build][:configure_path]

modules3rd_path = '/usr/local/nginx_build/modules3rd.ini'
modules3rd_path = node[:nginx_build][:modules3rd_path] if node[:nginx_build] && node[:nginx_build][:modules3rd_path]

nginx_modules3rds = []
nginx_modules3rds = node[:nginx_build][:modules3rds] if node[:nginx_build] && node[:nginx_build][:modules3rds]

nginx_version = "1.8.0"
nginx_version = node[:nginx_build][:nginx_version] if node[:nginx_build] && node[:nginx_build][:nginx_version]

build_user = node[:server][:user]
build_user = node[:nginx_build][:build_user] if node[:nginx_build] && node[:nginx_build][:build_user]

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

    notifies :run, 'execute[build-nginx]'
  end

end

if modules3rd_path =~ /^(.+)\/([^\/]+)$/
  directory $1

  template modules3rd_path do
    source "./templates/modules3rd.ini.erb"
    variables({
                  "nginx_modules3rds" => nginx_modules3rds
              })

    notifies :run, 'execute[build-nginx]'
  end

end

execute "build-nginx" do
  command "#{nginx_build_bin}nginx-build -d work -v #{nginx_version} -c #{configure_path} -m #{modules3rd_path} && \
           cd ~/work/nginx/#{nginx_version}/nginx-#{nginx_version} && sudo make install"
  user build_user
  action :nothing
end

template "/etc/init.d/nginx" do
  owner "root"
  group "root"
  mode "755"
  source "./templates/init_nginx.erb"
  variables({
                "nginx_sbin" => nginx_sbin,
                "nginx_conf" => nginx_conf,
                "nginx_pid"  => nginx_pid,
            })
  notifies :enable, 'service[nginx]', :delayed
  notifies :start, 'service[nginx]', :delayed
end

service 'nginx' do
  action [:enable, :start]
  only_if "test -f #{nginx_sbin}"
end
