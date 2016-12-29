defmodule Streamers.Api.Feeds do
  @moduledoc """
  Api for getting streams depends on specific user id
  """
  use Maru.Router

  alias Streamers.Models.Feeds
  alias Streamers.Models.Streams

  @doc """
  Requires to have api_key before to proceed streams or feeds API
  """
  plug Streamers.Api.Auth
  helpers Streamers.Api.AuthHelpers

  namespace :api do
    namespace :v1 do

      desc "Streams are collection for feeds ids based on unique id."
      namespace :streams do
        route_param :stream_id do

          resources :feeds do
            get do
              feeds = Feeds.all(current_user().id, params.stream_id)
              json conn, feeds
            end

            route_param :id do
              put "/like" do
                Streams.like(current_user().id, params.stream_id, params.id)
                conn
                |> put_status(200)
                |> json %{"status": "ok"}
              end

              put "/unlike" do
                Streams.unlike(current_user().id, params.stream_id, params.id)
                conn
                |> put_status(200)
                |> json %{"status": "ok"}
              end
            end
          end # :feeds
        end # route_param :id
      end # :streams

    end # v1
  end # api
end
