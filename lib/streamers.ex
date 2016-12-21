defmodule Streamers do
  use Application

  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Streamers.Api, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
