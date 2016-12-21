defmodule Streamers.Api.AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias RedisPoolex, as: Redis
  alias Streamers.ProtectedTest
  alias Streamers.Models.Registration

  doctest Streamers.Api.Auth

  require Logger

  defmodule ProtectedTest do
    use Plug.Router

    plug :match
    plug Streamers.Api.Auth
    plug :dispatch

    get "/protected" do
      conn
      |> send_resp(200, "API key: #{conn.assigns[:api_key]}")
    end
  end

  test "auth skip in case of no api-token" do
    Redis.query(["FLUSHDB"])

    conn = conn(:get, "/protected")

    response = call(ProtectedTest, conn)
    assert response.status == 403
  end

  test "auth continue to process in case of having api-token" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    conn = conn(:get, "/protected")
            |> put_req_header("x-api-key", user.api_key)

    response = call(ProtectedTest, conn)
    assert response.status == 200
    assert response.resp_body == "API key: #{user.api_key}"
  end

  test "wrong api token => forbidden" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{email: "alex.korsak@gmail.com"})

    conn = conn(:get, "/protected")
            |> put_req_header("x-api-key", "wrong-#{user.api_key}")

    response = call(ProtectedTest, conn)
    assert response.status == 403
  end

  defp call(mod, conn) do
    mod.call(conn, [])
  end
end
