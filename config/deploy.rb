set :application, "naar"
set :repo_url, "git@github.com:innoagostinelli/naar.git"
set :branch, :main
set :deploy_to, "/home/deploy/apps/naar"

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, File.read(File.join(File.dirname(__FILE__), "..", ".ruby-version")).strip

# Bundler
set :bundle_without, %w[development test]
set :bundle_flags, "--deployment --quiet"

# Archivos persistentes entre releases (nunca van al repo)
set :linked_files, %w[config/master.key]

# Directorios persistentes entre releases
set :linked_dirs, %w[
  storage
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  public/assets
]

set :keep_releases, 5

# Puma via systemd
set :puma_systemctl_user, :user
set :puma_service_unit_name, "puma_#{fetch(:application)}"
# capistrano3-puma no inyecta -C/-b en el ExecStart; el bind se controla desde
# config/puma.rb del propio repo, leyendo esta env var (ver PUMA_BIND ahí).
set :puma_service_unit_env_vars, -> { ["PUMA_BIND=unix://#{shared_path}/tmp/sockets/puma.sock"] }
# El linger ya se habilitó a mano una vez en el servidor (loginctl enable-linger deploy),
# así evitamos que capistrano3-puma intente correrlo vía sudo en cada `puma:enable`.
set :puma_enable_lingering, false
