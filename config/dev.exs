use Mix.Config

config :redis_poolex,
  reconnect: :no_reconnect,
  max_queue: :infinity,
  pool_size: 10,
  pool_max_overflow: 1,
  connection_string: "redis://streamers_redis:6379/"

config :logger, level: :debug, backends: [:console]
