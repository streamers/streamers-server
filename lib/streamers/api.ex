defmodule Requesters.Api do
  @moduledoc """
  module for making handshakes between Ruby and Elixir(storing metadata as streams/feeds in Redis).
  """
  use Maru.Router

  get "/alive" do
    text conn, "OK"
  end

  if Mix.env == :prod do
    rescue_from :all do
      conn
      |> put_status(500)
      |> text("Server Error")
    end
  end

  # plug Requesters.Api.Stats

  if Mix.env == :dev do
    use Plug.Debugger, otp_app: :requesters
  end

  plug Plug.Logger

  """
  should be on top because of using it without api token.
  """
  mount Requesters.Api.Stream.Users

  @doc """
  We are using api for dealing with streams/feeds and follow/unfollow actions
  Redis should store connections per user, stream(playlist), feed.
  Remaining metadata we are storing inside PostgreSQL.
  """
  mount Requesters.Api.Stream.Streams
  mount Requesters.Api.Stream.Feeds

  plug Plug.Static, at: "/dashboard", from: "/dashboard"
end
