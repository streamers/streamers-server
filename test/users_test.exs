defmodule Streamers.UsersTest do
  use ExUnit.Case
  doctest Streamers.Api.Users

  use Maru.Test, for: Streamers.Api.Users

  require Poison

  alias RedisPoolex, as: Redis

  test "response empty in case of no data inside redis" do
    Redis.query(["FLUSHDB"])

    response = conn(:post, "/api/v1/users",
                    email: "alex.korsak@gmail.com",
                    password: "123456",
                    password_confirmation: "123456") |> make_response
    assert response.status == 200
  end
end
