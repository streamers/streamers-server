defmodule Streamers.SuggestionsTest do
  use ExUnit.Case
  doctest Streamers.Models.Suggestions

  alias RedisPoolex, as: Redis
  alias Streamers.Models.Suggestions

  test "suggestions for streams" do
    Suggestions.streams_for(uid)
  end
end
