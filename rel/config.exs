Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: "${ERLANG_COOKIE}"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: "${ERLANG_COOKIE}"
end

release :checkers do
  set version: current_version(:checkers)
  set applications: [
    :runtime_tools
  ]
end