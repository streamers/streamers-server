defmodule Streamers.Models.Suggestions do
  alias RedisPoolex, as: Redis

  @moduledoc """
  `Suggestions` module containing different implementation of recommenders that
  could be applied for streams and feeds.
  """

  defmodule DefaultStrategy do
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
  def streams_for(uid, _options), do: streams_for(uid, DefaultStrategy)
  def streams_for(uid, _options, DefaultStrategy), do: DefaultStrategy.streams_for(uid)

  @doc """
  Recommend feeds based on liked, followed streams.
  """
  def feeds_for(uid, _options), do: feeds_for(uid, DefaultStrategy)
  def feeds_for(uid, _options, DefaultStrategy), do: DefaultStrategy.feeds_for(uid)
  def feeds_for(uid, _options, stream_id), do: DefaultStrategy.feeds_for(uid, stream_id)
  def feeds_for(uid, _options, stream_id, DefaultStrategy), do: DefaultStrategy.feeds_for(uid, stream_id)
end
