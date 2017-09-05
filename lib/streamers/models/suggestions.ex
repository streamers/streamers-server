defmodule Streamers.Models.Suggestions do
  alias RedisPoolex, as: Redis

  @moduledoc """
  `Suggestions` module containing different implementation of recommenders that
  could be applied for streams and feeds.
  """

  defmodule DefaultStrategy do
    require Logger

    def streams_for(uid) do
    end

    def feeds_for(uid) do
    end

    def feeds_for(uid, stream_id) do
    end
  end

  @doc """
  Recommend streams based on liked, followed streams and liked feeds.
  """
  def streams_for(uid, options), do: streams_for(uid, options, DefaultStrategy)
  def streams_for(uid, _options, strategy), do: strategy.streams_for(uid)

  @doc """
  Recommend feeds based on liked, followed streams.
  """
  def feeds_for(uid, options), do: feeds_for(uid, options, DefaultStrategy)
  def feeds_for(uid, options, strategy), do: strategy.feeds_for(uid)
  def feeds_for(uid, options, stream_id), do: feeds_for(uid, options, stream_id, DefaultStrategy)
  def feeds_for(uid, options, stream_id, strategy), do: strategy.feeds_for(uid, stream_id)
end
