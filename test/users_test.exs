defmodule Streamers.UsersTest do
  use ExUnit.Case
  doctest Streamers.Api.Users

  use Maru.Test, for: Streamers.Api.Users

  require Poison

  alias RedisPoolex, as: Redis

  setup_all do
    Redis.query(["FLUSHDB"])
    :ok
  end

  test "register new user by email, password" do
    response = conn(:post, "/api/v1/users",
                    email: "alex.korsak@gmail.com",
                    password: "123456",
                    password_confirmation: "123456") |> make_response
    assert response.status == 200
  end

  test "response errors in case of no password" do
    response = conn(:post, "/api/v1/users",
                    email: "alex.korsak@gmail.com",
                    password: "1",
                    password_confirmation: "123456") |> make_response
    assert response.status == 400
  end
end
