defmodule StructConstructor do
  @moduledoc """
  StructConstructor makes it easy to define typed structures using `Ecto.Schema` DSL.
  Such structures can later be easily initialized using function `new/1`.

  See `Ecto.Schema` documentation for more info about DSL.

  ## Example

      defmodule User do
        use StructConstructor do
          field :name, :string
          field :age, :integer
        end
      end

      iex> User.new(%{"name" => "Alex", "age" => "27"})
      %User{age: 27, name: "Alex"}

      iex> User.new(name: "Alex", age: "27"})
      %User{age: 27, name: "Alex"}
  """

  defmacro __using__(do: block) do
    quote location: :keep do
      use Ecto.Schema

      @primary_key false
      embedded_schema(do: unquote(block))

      @doc """
      Initialize `#{__MODULE__}` struct from map or keyword list
      """
      @spec new(map | Keyword.t()) :: struct
      def new(kwlist) when is_list(kwlist) do
        new(Map.new(kwlist))
      end

      def new(map) when is_map(map) do
        StructConstructor.new(__MODULE__, map)
      end

      @doc """
      Do something with `struct` after it's been instantiated
      """
      @spec after_load(struct) :: struct
      def after_load(struct),
        do: struct

      defoverridable after_load: 1
    end
  end

  alias Ecto.Changeset

  @doc false
  def new(mod, map) do
    mod
    |> struct()
    |> build_changeset(map)
    |> Changeset.apply_changes()
    |> after_load()
  end

  defp build_changeset(%mod{} = struct, map) do
    struct
    |> Changeset.cast(map, mod.__schema__(:fields) -- mod.__schema__(:embeds))
    |> cast_embeds(mod.__schema__(:embeds))
  end

  defp cast_embeds(changeset, []),
    do: changeset

  defp cast_embeds(changeset, [embed | rest]) do
    changeset
    |> Changeset.cast_embed(embed, with: &build_changeset/2)
    |> cast_embeds(rest)
  end

  defp after_load(%mod{} = struct) do
    after_load(struct, mod.__schema__(:embeds))
  end

  defp after_load(%mod{} = struct, []) do
    if function_exported?(mod, :after_load, 1) do
      mod.after_load(struct)
    else
      struct
    end
  end

  defp after_load(struct, [embed | rest]) do
    case struct do
      %{^embed => value} when is_list(value) ->
        struct
        |> Map.put(embed, Enum.map(value, &after_load/1))
        |> after_load(rest)

      %{^embed => value} when not is_nil(value) ->
        struct
        |> Map.put(embed, after_load(value))
        |> after_load(rest)

      _ ->
        after_load(struct, rest)
    end
  end
end
