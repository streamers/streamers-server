defmodule Streamers.Api.Feeds do
  @moduledoc """
  Api for getting streams depends on specific user id
  """
  use Maru.Router

  alias Streamers.Models.Feeds

  @doc """
  Requires to have api_key before to proceed streams or feeds API
  """
  plug Streamers.Auth

  namespace :api do
    namespace :v1 do

      desc "Streams are collection for feeds ids based on unique id."
      namespace :streams do
        route_param :stream_id do

          namespace :feeds do
            get do
              feeds = conn.assigns[:user].id |> Feeds.all(params.stream_id)
              json conn, feeds
            end
          end # :feeds
        end # route_param :id
      end # :streams

    end # v1
  end # api
end
