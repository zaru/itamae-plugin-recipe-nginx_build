def build_nginx_configure_options
  nginx_configure_options = %w(--with-http_ssl_module)
  if node[:nginx_build] && node[:nginx_build][:modules]
    nginx_configure_options = node[:nginx_build][:modules].map {|mod| "--with-#{mod}" }
  end
  if node[:nginx_build] && node[:nginx_build][:configure_options]
    nginx_configure_options |= node[:nginx_build][:configure_options].map {|k, v| "--#{k}=#{v}" }
  end
  nginx_configure_options
end

def openresty?
  node[:nginx_build] && node[:nginx_build][:build_target] && node[:nginx_build][:build_target] == 'openresty'
end

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

nginx_configure_options = build_nginx_configure_options

configure_path = '/usr/local/nginx_build/configure.sh'
configure_path = node[:nginx_build][:configure_path] if node[:nginx_build] && node[:nginx_build][:configure_path]

modules3rd_path = '/usr/local/nginx_build/modules3rd.ini'
modules3rd_path = node[:nginx_build][:modules3rd_path] if node[:nginx_build] && node[:nginx_build][:modules3rd_path]

nginx_modules3rds = []
nginx_modules3rds = node[:nginx_build][:modules3rds] if node[:nginx_build] && node[:nginx_build][:modules3rds]

build_user = node[:server][:user]
build_user = node[:nginx_build][:build_user] if node[:nginx_build] && node[:nginx_build][:build_user]

configure_command = "#{nginx_build_bin}nginx-build -d work -c #{configure_path} -m #{modules3rd_path}"
work_dir = ''
if openresty?
  openresty_version = '1.11.2.2'
  openresty_version = node[:nginx_build][:openresty_version] if node[:nginx_build] && node[:nginx_build][:openresty_version]
  configure_command << " -openresty -openrestyversion #{openresty_version}"
  work_dir = "~/work/openresty/#{openresty_version}/openresty-#{openresty_version}"
else
  nginx_version = '1.8.0'
  nginx_version = node[:nginx_build][:nginx_version] if node[:nginx_build] && node[:nginx_build][:nginx_version]
  configure_command << " -v #{nginx_version}"
  work_dir = "~/work/nginx/#{nginx_version}/nginx-#{nginx_version}"
end
nginx_build_command = "#{configure_command} && cd #{work_dir} && sudo make install"

if configure_path =~ /^(.+)\/([^\/]+)$/
  directory $1

  template configure_path do
    source "./templates/configure.sh.erb"
    variables({
                  "nginx_user"              => nginx_user,
                  "nginx_group"             => nginx_group,
                  "nginx_sbin"              => nginx_sbin,
                  "nginx_conf"              => nginx_conf,
                  "nginx_pid"               => nginx_pid,
                  "nginx_configure_options" => nginx_configure_options,
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
  command nginx_build_command
  user build_user
  action :nothing
end

case node[:platform]
when 'debian', 'ubuntu', 'mint'
  init_nginx_template_path = "./templates/init_nginx_debian.erb"
else
  init_nginx_template_path = "./templates/init_nginx.erb"
end

template "/etc/init.d/nginx" do
  owner "root"
  group "root"
  mode "755"
  source init_nginx_template_path
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
