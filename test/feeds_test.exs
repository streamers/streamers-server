defmodule Requesters.Api.FeedsTest do
  use ExUnit.Case
  doctest Requesters.Api.Stream.Feeds

  use Maru.Test, for: Requesters.Api.Stream.Feeds

  require Poison

  alias RedisPoolex, as: Redis
  alias Requesters.Api.Models.Streams
  alias Requesters.Api.Models.Feeds
  alias Requesters.Api.Models.Registration

  test "response empty in case of no data inside redis for feeds" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    uid = "1"

    {:ok, stream} = uid |> Streams.create(%{name: "new-name-1"})

    response = conn(:get, "/api/v1/streams/#{stream.id}/feeds", uid: uid)
                |> put_req_header("x-api-key", user.api_key)
                |> make_response
    assert response.status == 200
    assert response.resp_body == "\[\]"
  end

  test "response list of feeds" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    {:ok, stream} = uid |> Streams.create(%{name: "new-name"})
    {:ok, feed} = uid |> Feeds.create(stream.id, %{id: "1", timestamp: 1})

    response = conn(:get, "/api/v1/streams/#{stream.id}/feeds", uid: uid)
                |> put_req_header("x-api-key", user.api_key)
                |> make_response
    assert response.status == 200
    assert response.resp_body == Poison.encode!([feed])
  end
end
