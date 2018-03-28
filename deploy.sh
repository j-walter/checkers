#!/bin/bash

export PORT=5102
export MIX_ENV=prod

INITIAL_DIR=`pwd`


if [ ! $(id -u) = 0 ]; then
  exit 1
fi

POSTGRES_PASSWORD=$(openssl rand -base64 32)
SECRET_KEY_BASE=$(openssl rand -base64 64)

echo "
use Mix.Config
config :checkers, Checkers.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: \"checkers\",
  password: \"$POSTGRES_PASSWORD\",
  database: \"checkers\",
  hostname: \"localhost\",
  pool_size: 10
config :checkers, Checkers.Endpoint,
    secret_key_base: \"$SECRET_KEY_BASE\"
" > $INITIAL_DIR/config/prod.secret.exs

chown checkers:checkers "$INITIAL_DIR/config/prod.secret.exs"
chown checkers:checkers "/home/checkers/" -R

su postgres -c "psql -c \"CREATE USER checkers;\""
su postgres -c "psql -c \"ALTER USER checkers WITH PASSWORD '${POSTGRES_PASSWORD}';\""
su postgres -c "psql -c \"CREATE DATABASE checkers;\""
su postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE checkers to checkers;\""

su checkers -c "
cd "$INITIAL_DIR"
mix deps.get
(cd assets && npm install)
(cd assets && npm rebuild node-sass)
(cd assets && ./node_modules/brunch/bin/brunch b -p)
mix phx.digest
MIX_ENV=prod mix ecto.create
MIX_ENV=prod mix ecto.migrate
ERLANG_COOKIE=\"$(openssl rand -base64 64)\" REPLACE_OS_VARS=true MIX_ENV=prod mix release
mkdir -p ~/www
mkdir -p ~/old
NOW=\$(date +%s)
if [ -d ~/www/checkers ]; then
	echo mv ~/www/checkers ~/old/\$NOW
	mv ~/www/checkers ~/old/\$NOW
fi
mkdir -p ~/www/checkers
REL_TAR=\"$INITIAL_DIR/_build/prod/rel/checkers/releases/0.0.1/checkers.tar.gz\"
echo \"Extracting \$REL_TAR to ~/www/checkers\"
(cd ~/www/checkers && tar xzf \$REL_TAR)
crontab - <<CRONTAB
@reboot bash $INITIAL_DIR/start.sh
CRONTAB
"