defmodule Streamers.SuggestionsTest do
  use ExUnit.Case
  doctest Streamers.Models.Suggestions

  alias RedisPoolex, as: Redis
  alias Streamers.Models.Suggestions
  alias Streamers.Models.Streams

  require Logger

  setup do
    Redis.query(["FLUSHDB"])
    :ok
  end

  require IEx

  @uid 1
  test "liked stream should be first" do
    {:ok, stream1} = Streams.create(@uid, %{name: "test 1"})
    {:ok, stream2} = Streams.create(@uid, %{name: "test 2"})
    {:ok, stream3} = Streams.create(@uid, %{name: "test 2"})

    :ok = Streams.like(@uid, stream2.id)

    # TODO:
    #
    # STREAMS:
    # - should get followed streams
    # - should get liked streams by followed users
    # - should distract my own streams
    # - should rank it by most met streams
    # - should return streams
    #
    # FEEDS:
    # - should get liked feeds of followed users
    # - should find most likable feeds and sort it
    #
    # FEEDS should be 1000< size somehow.

    suggestions = Suggestions.streams_for(@uid, batch: 1)
    assert stream2.id == suggestions |> List.first |> Map.get(:id)
  end

  test "unliked stream should be in last" do
    {:ok, stream1} = Streams.create(@uid, %{name: "test 1"})
    {:ok, stream2} = Streams.create(@uid, %{name: "test 2"})
    {:ok, stream3} = Streams.create(@uid, %{name: "test 2"})

    :ok = Streams.like(@uid, stream2.id)
    :ok = Streams.like(@uid, stream3.id)

    suggestions = Suggestions.streams_for(@uid, batch: 3)
    assert stream1.id == suggestions |> List.last |> Map.get(:id)
  end
end
