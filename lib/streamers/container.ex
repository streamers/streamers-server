defmodule Requesters.Api.Container do
  defmodule Stream do
    defstruct uid: nil, id: nil, name: nil
  end

  defmodule Feed do
    defstruct stream_id: nil, id: nil, timestamp: nil
  end

  defmodule User do
    defstruct id: nil, email: nil, api_key: nil
  end
end
