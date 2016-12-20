defmodule Requesters.Api.Models.Feeds do
  alias RedisPoolex, as: Redis

  require Requesters.Api.Container

  alias Requesters.Api.Container.Stream
  alias Requesters.Api.Container.Feed
  alias Requesters.Api.Models.Validator


  def create(uid, stream_id, attributes) do
    attributes |> Dict.merge(stream_id: stream_id, uid: uid) |> _validate |> _create
  end


  def destroy(uid, stream_id, id) do
    Redis.query_pipe([
      ["zrem", uid |> _unique_records_key(stream_id, "original"), id],
      ["zrem", uid |> _unique_records_key(stream_id, "merged"), id],
    ])
  end

  defp _validate(attributes) do
    errors = []

    errors
    |> Validator.requires(:stream_id, attributes[:stream_id])
    |> Validator.requires(:uid, attributes[:uid])
    |> Validator.requires(:id, attributes[:id])
    |> Validator.requires(:timestamp, attributes[:timestamp])
    |> Validator.finish(attributes)
  end

  defp _create({attributes, :ok}) do
    followers = Redis.query(["smembers", "st:#{attributes.uid}:#{attributes.stream_id}:fs"])
    |> Enum.map fn(id) ->
      ["zadd", "st:#{attributes.uid}:#{id}:fm", attributes.timestamp, attributes.id]
    end

    Redis.query_pipe([
      ["zadd", attributes.uid |> _unique_records_key(attributes.stream_id, "original"), attributes.timestamp, attributes.id],
      ["zadd", attributes.uid |> _unique_records_key(attributes.stream_id, "merged"), attributes.timestamp, attributes.id],
    ] ++ followers)

    stream = struct(Feed, attributes)

    {:ok, stream}
  end
  defp _create({:error, errors} = response), do: response


  @doc """
  we can take a look feeds from merged(followed streams) or original version.
  """
  def all(uid, stream_id, from \\ "merged") do
    key = uid |> _unique_records_key(stream_id, from)

    Redis.query(["zrevrange", key, 0, -1, "WITHSCORES"]) # 0 = offset, -1 = offset + limit - 1
    |> _pack([])
    |> Enum.map &find(uid, stream_id, &1)
  end

  defp _pack([], collector), do: collector
  defp _pack(array, collector) do
    array0 = List.first(array)
    array = array |> List.delete_at(0)

    array1 = List.first(array) |> String.to_integer
    array = array |> List.delete_at(0)

    _pack(array, collector ++ [%{id: array0, timestamp: array1}])
  end

  defp find(uid, stream_id, attributes) do
    attributes = attributes |> Dict.merge(%{uid: uid, stream_id: stream_id})
    struct(Feed, attributes)
  end

  @doc """
  we are getting first letter of name and making the key like "f{letter}"

  `fm` - merged feeds
  `fo` - original feeds
  """
  defp _unique_records_key(uid, stream_id, name) do
    letter = name |> String.codepoints |> List.first
    "st:#{uid}:#{stream_id}:f#{letter}"
  end
end
