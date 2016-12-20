defmodule Requesters.Api.Stream.StreamsTest do
  use ExUnit.Case

  alias Requesters.Api.Models.Streams
  alias Requesters.Api.Models.Feeds
  alias Requesters.Api.Models.Subscriber
  alias RedisPoolex, as: Redis

  test "get all streams from redis storage" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    streams = uid |> Streams.all
    assert streams == [stream1]

    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})
    streams = uid |> Streams.all
    assert streams == [stream1, stream2]
  end

  test "find record by id" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})
    stream = uid |> Streams.find(stream2.id)
    assert stream == stream2
  end

  test "delete record by id" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})

    uid |> Streams.destroy(stream2.id)

    stream = uid |> Streams.find(stream2.id)
    assert stream == nil

    stream = uid |> Streams.find(stream1.id)
    assert stream == stream1
  end

  test "create new feeds" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, feed} = uid |> Feeds.create(stream.id, %{id: "assigned-id", timestamp: 1})

    assert feed.id == "assigned-id"
    assert feed.timestamp == 1
    assert feed.stream_id == stream.id
  end

  test "get the list of the new feeds" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, feed1} = uid |> Feeds.create(stream.id, %{id: "assigned-id-1", timestamp: 1})
    {:ok, feed2} = uid |> Feeds.create(stream.id, %{id: "assigned-id-2", timestamp: 2})

    assert feed1.id == "assigned-id-1"
    assert feed1.timestamp == 1
    assert feed1.stream_id == stream.id

    assert feed2.id == "assigned-id-2"
    assert feed2.timestamp == 2
    assert feed2.stream_id == stream.id

    feeds = uid |> Feeds.all(stream.id)
    assert feeds == [feed2, feed1] # should be sorted by timestamp
  end

  test "destroy feed from the new feeds" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, feed1} = uid |> Feeds.create(stream.id, %{id: "assigned-id-1", timestamp: 1})
    {:ok, feed2} = uid |> Feeds.create(stream.id, %{id: "assigned-id-2", timestamp: 2})

    feeds = uid |> Feeds.all(stream.id)
    assert feeds == [feed2, feed1] # should be sorted by timestamp

    uid |> Feeds.destroy(stream.id, feed2.id)
    feeds = uid |> Feeds.all(stream.id)
    assert feeds == [feed1] # should be sorted by timestamp

    uid |> Feeds.destroy(stream.id, feed1.id)
    feeds = uid |> Feeds.all(stream.id)
    assert feeds == [] # should be sorted by timestamp
  end

  require Logger

  test "follow from one stream to second one stream and create after that one more post for subscribed" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})

    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == []

    {:ok, feed1} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-1", timestamp: 1})
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed1]

    uid |> Subscriber.follow(stream1.id, stream2.id)

    {:ok, feed2} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-2", timestamp: 2})
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed2, feed1]

    {:ok, feed3} = uid |> Feeds.create(stream2.id, %{id: "assigned-id-3", timestamp: 3})
    feeds = uid |> Feeds.all(stream2.id)
    assert feeds == [feed3]

    feeds = uid |> Feeds.all(stream1.id)

    feed3 = %{feed3 | stream_id: stream1.id}
    assert feeds == [feed3, feed2, feed1]
  end

  test "follow from one stream to second one stream" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})

    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == []

    {:ok, feed1} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-1", timestamp: 1})
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed1]

    {:ok, feed2} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-2", timestamp: 2})
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed2, feed1]

    {:ok, feed3} = uid |> Feeds.create(stream2.id, %{id: "assigned-id-3", timestamp: 3})
    feeds = uid |> Feeds.all(stream2.id)
    assert feeds == [feed3]

    uid |> Subscriber.follow(stream1.id, stream2.id)

    # We should use stream1.id because now it's part of stream1
    feed3 = %{feed3 | stream_id: stream1.id}

    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed3, feed2, feed1]
  end

  test "follow from one stream to second one stream should have unique feeds and highest rank" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})

    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == []

    {:ok, feed1} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-1", timestamp: 1})
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed1]

    {:ok, feed2} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-2", timestamp: 2})
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed2, feed1]

    {:ok, feed3} = uid |> Feeds.create(stream2.id, %{id: "assigned-id-1", timestamp: 3})
    feeds = uid |> Feeds.all(stream2.id)
    assert feeds == [feed3]

    uid |> Subscriber.follow(stream1.id, stream2.id)

    feed3 = %{feed3 | stream_id: stream1.id}
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed3, feed2]
  end

  test "unfollow from one stream from another" do
    Redis.query(["FLUSHDB"])

    uid = "1"

    {:ok, stream1} = uid |> Streams.create(%{name: "new-name-1"})
    {:ok, stream2} = uid |> Streams.create(%{name: "new-name-2"})

    feeds = uid |> Feeds.all(stream1.id)
    {:ok, feed1} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-1", timestamp: 1})
    {:ok, feed2} = uid |> Feeds.create(stream1.id, %{id: "assigned-id-2", timestamp: 2})
    {:ok, feed3} = uid |> Feeds.create(stream2.id, %{id: "assigned-id-3", timestamp: 3})

    uid |> Subscriber.follow(stream1.id, stream2.id)
    feeds = uid |> Feeds.all(stream1.id)

    feed3 = %{feed3 | stream_id: stream1.id}
    assert feeds == [feed3, feed2, feed1]

    uid |> Subscriber.unfollow(stream1.id, stream2.id)
    feeds = uid |> Feeds.all(stream1.id)
    assert feeds == [feed2, feed1]
  end
end
