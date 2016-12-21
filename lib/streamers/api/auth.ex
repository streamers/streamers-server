defmodule Streamers.Api.UserVerification do
  import Plug.Conn
  alias Plug.Conn.Status

  def init(options), do: options

  require Logger

  alias Streamers.Models.Registration

  """
  Plug should halt connection in case of missing user information in the database by passed api token.
  """
  def call(conn, _opts) do
    if conn.halted do
      conn
    else
      case Registration.find_by_api_key(conn.assigns[:api_key]) do
        {:ok, user} ->
          conn
          |> assign(:user, user)
        {:error, _messages} ->
          conn
          |> put_status(Status.code(:forbidden))
          |> halt
      end
    end
  end
end

defmodule Streamers.Api.Auth do
  use Plug.Builder

  """
  Module for requiring auth tokens before to proceed any requests to API

  param: x-api-key is require in header.
  """
  plug PlugRequireHeader, headers: [api_key: "x-api-key"]
  """
  Checking by api_key that we have user in database and it's allowed to access API
  """
  plug Streamers.Api.UserVerification
end
