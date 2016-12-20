defmodule Requesters.Api.StreamsTest do
  use ExUnit.Case
  doctest Requesters.Api.Stream.Streams

  use Maru.Test, for: Requesters.Api.Stream.Streams

  require Poison

  alias RedisPoolex, as: Redis
  alias Requesters.Api.Models.Streams
  alias Requesters.Api.Models.Registration

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
