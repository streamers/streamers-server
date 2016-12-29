defmodule Streamers.Api.Users do
  @moduledoc """
  Api for registrations/updating details
  """
  use Maru.Router

  alias Streamers.Models.Registration

  namespace :api do
    namespace :v1 do
      @doc """
      We should allow to register by invitation code for now until
      we get approve to make public for the registartions.
      """
      namespace :users do
        params do
          requires :email, type: String
          requires :password, type: String
          requires :password_confirmation, type: String
        end
        post do
          case Registration.create(%{email: params.email}) do
            {:ok, user} ->
              json conn, %{id: user.id, email: user.email, api_key: user.api_key}
            {:error, errors} ->
              conn
              |> put_status(400)
              |> json %{errors: errors}
          end
        end
      end # users

    end # v1
  end # api
end
