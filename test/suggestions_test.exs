defmodule Streamers.SuggestionsTest do
  use ExUnit.Case
  doctest Streamers.Models.Suggestions

  alias RedisPoolex, as: Redis
  alias Streamers.Models.Suggestions
  alias Streamers.Models.Streams

  setup do
    Redis.query(["FLUSHDB"])
    :ok
  end

  @uid 1
  test "liked stream should be first" do
    {:ok, stream1} = Streams.create(@uid, %{name: "test 1"})
    {:ok, stream2} = Streams.create(@uid, %{name: "test 2"})
    {:ok, stream3} = Streams.create(@uid, %{name: "test 2"})

    :ok = Streams.like(@uid, stream2.id)

    assert stream2.id == Suggestions.streams_for(@uid, batch: 1) |> Enum.first |> Map.get(:id)
  end

  test "unliked stream should be in last" do
    {:ok, stream1} = Streams.create(@uid, %{name: "test 1"})
    {:ok, stream2} = Streams.create(@uid, %{name: "test 2"})
    {:ok, stream3} = Streams.create(@uid, %{name: "test 2"})

    :ok = Streams.like(@uid, stream2.id)
    :ok = Streams.like(@uid, stream3.id)

    assert stream1.id == Suggestions.streams_for(@uid, batch: 3) |> Enum.last |> Map.get(:id)
  end
end
