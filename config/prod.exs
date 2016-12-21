use Mix.Config

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "redis://#{System.get_env("REDIS_HOST")/"

config :logger, level: :error, backends: [:console]
