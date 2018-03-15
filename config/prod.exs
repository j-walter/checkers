use Mix.Config

config :checkers, CheckersWeb.Endpoint,
server: true,
  load_from_system_env: true,
  url: [host: "checkers.loopback.onl", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  root: "."
config :logger, level: :info
config :phoenix, :stacktrace_depth, 20

import_config "prod.secret.exs"