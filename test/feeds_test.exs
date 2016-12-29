defmodule Streamers.FeedsTest do
  use ExUnit.Case
  doctest Streamers.Api.Feeds

  use Maru.Test, for: Streamers.Api.Feeds

  require Poison

  alias RedisPoolex, as: Redis
  alias Streamers.Models.Streams
  alias Streamers.Models.Feeds
  alias Streamers.Models.Registration

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

  test "like object_id for stream and user" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })
    {:ok, stream} = Streams.create(user.id, %{name: "new-name"})

    # We should have object inside of stream, otherwise it's not persisted.
    {:ok, feed} = Feeds.create(user.id, stream.id, %{id: "1", timestamp: 1})

    # /api/v1/streams/:id/objects/:object_id/like
    response = conn(:put, "/api/v1/streams/#{stream.id}/feeds/#{feed.id}/like")
                |> put_req_header("x-api-key", user.api_key)
                |> make_response
    assert response.status == 200
    assert 1 == Streams.likes |> Enum.count
    assert feed.id == stream.id |> Streams.likes |> Enum.first

    response = conn(:put, "/api/v1/streams/#{stream.id}/feeds/#{feed.id}/unlike")
                |> put_req_header("x-api-key", user.api_key)
                |> make_response
    assert response.status == 200
    assert 0 == Streams.likes |> Enum.count
  end
end
