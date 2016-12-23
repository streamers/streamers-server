defmodule Streamers.Models.Attributes do
  def build(array), do: build(%{}, array)
  def build(collector, nil), do: collector
  def build(collector, []), do: collector
  def build(collector, array) do
    array0 = List.first(array) |> String.to_atom
    array = array |> List.delete_at(0)

    array1 = List.first(array)
    array = array |> List.delete_at(0)

    collector
    |> Dict.put_new(array0, array1)
    |> build(array)
  end

  def finish(record_attributes, struct_module) do
    if map_size(record_attributes) == 0 do
      nil
    else
      struct(struct_module, record_attributes)
    end
  end
end
