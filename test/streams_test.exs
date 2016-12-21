defmodule Streamers.ApisTest do
  use ExUnit.Case
  doctest Streamers.Api.Streams

  use Maru.Test, for: Streamers.Api.Streams

  require Poison

  alias RedisPoolex, as: Redis
  alias Streamers.Models.Streams
  alias Streamers.Models.Registration

  test "response empty in case of no data inside redis" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    response = conn(:get, "/api/v1/streams")
                |> put_req_header("x-api-key", user.api_key)
                |> make_response
    assert response.status == 200
    assert response.resp_body == "\[\]"
  end

  test "response list streams" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    {:ok, stream} = user.id |> Streams.create(%{name: "new-name"})

    response = conn(:get, "/api/v1/streams")
                |> put_req_header("x-api-key", user.api_key)
                |> make_response
    assert response.status == 200
    assert response.resp_body == Poison.encode!([stream])
  end
end
