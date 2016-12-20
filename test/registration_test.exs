defmodule Requesters.Api.Stream.RegistrationTest do
  use ExUnit.Case

  alias Requesters.Api.Models.User
  alias Requesters.Api.Models.Registration
  alias RedisPoolex, as: Redis

  test "create one more user in redis and generate api token for further accessing API" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })
    assert user.id != nil
    assert user.email == "alex.korsak@gmail.com"
    assert user.api_key != nil
  end

  test "skip creation because of missing attributes" do
    Redis.query(["FLUSHDB"])

    {:error, _messages} = Registration.create(%{ name: "Alexandr Korsak" })
  end

  test "find by api token" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    {:ok, user} = Registration.find_by_api_key(user.api_key)

    assert user.id != nil
    assert user.email == "alex.korsak@gmail.com"
  end

  test "not find by wrong api token" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    {:error, _errors} = Registration.find_by_api_key("wrong-#{user.api_key}")
  end

  test "check uniqueness for email" do
    Redis.query(["FLUSHDB"])

    {:ok, user} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    {:error, errors} = Registration.create(%{ email: "alex.korsak@gmail.com" })

    assert errors == ["email should be unique"]
  end
end
