defmodule Requesters.Api.Models.Streams do
  alias RedisPoolex, as: Redis

  require Requesters.Api.Container

  alias Requesters.Api.Container.Stream
  alias Requesters.Api.Container.Feed
  alias Requesters.Api.Models.Attributes
  alias Requesters.Api.Models.Validator

  @moduledoc """
  Module for storing streams(playlists) as part of redis db.

  required attributes:
  - name
  - uid - unique id from authentication system for easy split data in specific keys in redis
  """
  def all(uid) do
    key = uid |> _unique_records_key
    Redis.query(["smembers", key]) |> Enum.map &find(uid, &1)
  end

  @doc """
  `find` for searching streams in Redis
  """
  def find(uid, id) do
    key = uid |> _unique_record_key(id)
    Redis.query(["hgetall", key])
    |> Attributes.build
    |> Attributes.finish(Stream)
  end

  def destroy(uid, id) do
    Redis.query_pipe([
      ["srem", uid |> _unique_records_key, id],
      ["del", uid |> _unique_record_key(id)],
    ])
  end

  @doc """
  Storing records to Redis depends on `uid`
  """
  def create(uid, attributes) do
    attributes |> Dict.merge(uid: uid) |> _validate |> _create
  end

  defp _create({attributes, :ok}) do
    id = _unique_id(attributes.uid)
    record_key = _unique_record_key(attributes.uid, id)

    Redis.query_pipe([
      ["hmset", record_key,
       "name", attributes.name,
       "id", id,
       "uid", attributes.uid],
      ["sadd",  _unique_records_key(attributes.uid), id]
    ])

    attributes = attributes |> Dict.merge(id: id)

    stream = struct(Stream, attributes)

    {:ok, stream}
  end
  defp _create({:error, errors} = response), do: response


  defp _validate(attributes) do
    errors = []

    errors
    |> Validator.requires(:name, attributes[:name])
    |> Validator.requires(:uid, attributes[:uid])
    |> Validator.finish(attributes)
  end


  @doc """
  Generate unique id using atomic redis incrementation operation per key. Usually it's basic way to make primary key.
  """
  defp _unique_id(uid) do
    Redis.query(["incr", "st:#{uid}"])
  end

  defp _unique_key(uid) do
    "st:#{uid}"
  end

  defp _unique_record_key(uid, id) do
    key = uid |> _unique_key
    "#{key}:#{id}"
  end

  @doc """
  Storing ids as part of collection for faster access to all available ids.

  `rs` - streams
  """
  defp _unique_records_key(uid) do
    key = uid |> _unique_key
    "#{key}:rs"
  end
end
