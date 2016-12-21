defmodule Streamers.Models.Registration do
  alias RedisPoolex, as: Redis

  require UUID
  require Streamers.Container

  alias Streamers.Container.User
  alias Streamers.Models.Attributes
  alias Streamers.Models.Validator

  require Logger

  """
  Method should generate new uid for user and create new api_key for using it for
  accessing to API.
  """
  def create(attributes) do
    attributes
    |> Dict.merge(api_key: UUID.uuid4())
    |> _validate
    |> _create
  end

  defp _create({attributes, :ok}) do
    id = _unique_id
    record_key = _unique_record_key(id)

    Redis.query_pipe([
      ["hmset", record_key,
       "email", attributes.email,
       "id", id,
       "api_key", attributes.api_key],
      ["set", "usr:#{attributes.api_key}", id],
      ["sadd",  _unique_records_key, id],
      ["sadd",  "usr:emails", attributes.email],
    ])

    attributes = attributes |> Dict.merge(id: id)

    user = struct(User, attributes)

    {:ok, user}
  end
  defp _create({:error, errors} = response), do: response

  def get(id) do
    record_key = _unique_record_key(id)

    [email, api_key] = Redis.query(["hmget", record_key, "email", "api_key"])

    user = struct(User, %{email: email, api_key: api_key, id: id})

    {:ok, user}
  end

  def find_by_api_key(token) do
    id = Redis.query(["get", "usr:#{token}"])
    _find_by_api_key(id)
  end
  defp _find_by_api_key(:undefined), do: {:error, ["could not find by token"]}
  defp _find_by_api_key(id), do: get(id)

  defp _validate(attributes) do
    errors = []

    errors
    |> Validator.requires(:api_key, attributes[:api_key])
    |> Validator.requires(:email, attributes[:email])
    |> Validator.uniqueness(:email, attributes[:email], fn(v) ->
      Redis.query(["sismember", "usr:emails", v]) == "1"
    end)
    |> Validator.finish(attributes)
  end

  @doc """
  urs should have unique number
  """
  defp _unique_id do
    Redis.query(["incr", "usr"])
  end

  defp _unique_record_key(id) do
    "usr:#{id}"
  end

  defp _unique_records_key do
    "usr:rs"
  end
end
