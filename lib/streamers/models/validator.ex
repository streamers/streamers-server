defmodule Requesters.Api.Models.Validator do
  @moduledoc """
  Validator for having required validatation for attributes on create.

  it should work as part of pipeline like:

  `validate |> create`

  """
  def finish([], attributes), do: {attributes, :ok}
  def finish(errors, _attributes), do: {:error, errors}

  def requires(errors, field, nil), do: errors ++ ["#{field} is required"]
  def requires(errors, field, ""), do: errors ++ ["#{field} is required"]
  def requires(errors, field, :undefined), do: errors ++ ["#{field} is required"]
  def requires(errors, field, _value), do: errors

  def uniqueness(errors, field, value, check_fn), do: _uniqueness(errors, field, value, check_fn)
  defp _uniqueness(errors, field, nil, _check_fn), do: errors ++ ["#{field} is missing"]
  defp _uniqueness(errors, field, "", _check_fn), do: errors ++ ["#{field} is missing"]
  defp _uniqueness(errors, field, :undefined, check_fn), do: errors ++ ["#{field} is missing"]
  defp _uniqueness(errors, field, value, check_fn) do
    unless check_fn.(value) do
      errors
    else
      errors ++ ["#{field} should be unique"]
    end
  end
end
