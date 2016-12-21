defmodule Streamers.Api.Streams do
  @moduledoc """
  Api for getting streams depends on specific user id
  """
  use Maru.Router

  @doc """
  Requires to have api_key before to proceed streams or feeds API
  """
  plug Streamers.Auth

  alias Streamers.Models.Streams
  alias Streamers.Models.Subscriber

  namespace :api do
    namespace :v1 do

      desc "Streams are collection for feeds ids based on unique id."
      namespace :streams do
        get do
          streams = conn.assigns[:user].id |> Streams.all
          json conn, streams
        end

        params do
          requires :name, type: String
        end
        post do
          stream = conn.assigns[:user].id |> Streams.create(%{name: params.name})
          json conn, stream
        end

        params do
          requires :stream_id1, type: String
          requires :stream_id2, type: String
        end
        put "/follow" do
          conn.assigns[:user] |> Subscriber.follow(params.stream_id1, params.stream_id2)
          json conn, %{status: "OK"}
        end

        params do
          requires :stream_id1, type: String
          requires :stream_id2, type: String
        end
        put "/unfollow" do
          conn.assigns[:user] |> Subscriber.unfollow(params.stream_id1, params.stream_id2)
          json conn, %{status: "OK"}
        end

        # TODO: add UPDATE method for Stream
        route_param :id do
          get do
            stream = conn.assigns[:user].id |> Streams.find(params.id)
            json conn, stream
          end

          delete do
            conn.assigns[:user].id |> Streams.destroy(params.id)
            conn
            |> put_status(200)
          end
        end
      end

    end # v1
  end # api
end
