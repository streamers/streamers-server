defmodule Streamers.Models.Subscriber do
  alias RedisPoolex, as: Redis

  @moduledoc """
  We should subscribe/unsubscribe streams.

  - original streams should contain only original feeds
  - subscribed streams should contain feeds from original + subscribers
  - subscribed streams should be sorted by timestamp
  - feeds reader for streams should contains merged data in case of making requests for default stream.
  - stream(playlist) should be possible to read original tracks from there.

  `st` - streams
  `fd` - followed
  `fs` - followers
  """

  @doc """
  - method should store stream_id2 as follower for stream_id1
  - method should merge stream1 + stream2
  """
  def follow(uid, stream_id1, stream_id2) do
    to = uid |> _unique_records_key(stream_id1, "merged")
    from = uid |> _unique_records_key(stream_id2, "original")

    Redis.query_pipe([
      ["sadd", "st:#{uid}:#{stream_id1}:fd", stream_id2],
      ["sadd", "st:#{uid}:#{stream_id2}:fs", stream_id1],
      ["ZUNIONSTORE", to, 2, to, from, "AGGREGATE", "MAX"], # 0 = offset, -1 = offset + limit - 1
    ])
  end


  @doc """
  Unfollow stream_id2 from stream_id1, we should remove feeds from merged collection of stream1
  """
  def unfollow(uid, stream_id1, stream_id2) do
    to = uid |> _unique_records_key(stream_id1, "merged")
    from = uid |> _unique_records_key(stream_id2, "original")

    Redis.query_pipe([
      ["srem", "st:#{uid}:#{stream_id1}:fd", stream_id2],
      ["srem", "st:#{uid}:#{stream_id2}:fs", stream_id1],
      ["del", to],
    ])

    followed = Redis.query(["smembers", "st:#{uid}:#{stream_id1}:fd"])
    followed = followed ++ [stream_id1]
    followed = followed
    |> Enum.map &_unique_records_key(uid, &1, "original")

    # TODO: replace it by using exredis raw query instead of using macro
    Redis.query(["ZUNIONSTORE", to, Enum.count(followed)] ++ followed ++ ["AGGREGATE", "MAX"])
  end


  @doc """
  we are getting first letter of name and making the key like "f{letter}"
  """
  defp _unique_records_key(uid, stream_id, name) do
    letter = name |> String.codepoints |> List.first
    "st:#{uid}:#{stream_id}:f#{letter}"
  end
end
