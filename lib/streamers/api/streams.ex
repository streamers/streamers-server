defmodule Streamers.Api.Streams do
  @moduledoc """
  Api for getting streams depends on specific user id
  """
  use Maru.Router

  @doc """
  Requires to have api_key before to proceed streams or feeds API
  """
  plug Streamers.Api.Auth
  helpers Streamers.Api.AuthHelpers

  alias Streamers.Models.Streams
  alias Streamers.Models.Subscriber

  namespace :api do
    namespace :v1 do

      desc "Streams are collection for feeds ids based on unique id."
      resources :streams do
        get do
          streams = Streams.all(current_user().id)
          json conn, streams
        end

        params do
          requires :name, type: String
        end
        post do
          stream = Streams.create(current_user().id, %{name: params.name})
          json conn, stream
        end

        params do
          requires :stream_id1, type: String
          requires :stream_id2, type: String
        end
        put "/follow" do
          Subscriber.follow(current_user().id, params.stream_id1, params.stream_id2)
          put_status(conn, 200)
        end

        params do
          requires :stream_id1, type: String
          requires :stream_id2, type: String
        end
        put "/unfollow" do
          Subscriber.unfollow(current_user().id, params.stream_id1, params.stream_id2)
          put_status(conn, 200)
        end

        route_param :id do
          get do
            stream = Streams.find(current_user().id, params.id)
            json conn, stream
          end

          delete do
            Streams.destroy(current_user().id, params.id)
            put_status(conn, 200)
          end
        end # objects
      end

    end # v1
  end # api
end
