defmodule Requesters.Api.Stats do
  @behaviour Plug

  import Plug.Conn, only: [register_before_send: 2]

  # use Elixometer

  def init(opts), do: opts

  def call(conn, _config) do
    conn

    # before_time = :os.timestamp

    # register_before_send conn, fn conn ->
    #   after_time = :os.timestamp
    #   diff       = :timer.now_diff after_time, before_time

    #   update_counter("aggregator.webapp.resp_count", 1)
    #   update_histogram("aggregator.webapp.resp_time", diff / 1_000)

    #   conn
    # end
  end
end
