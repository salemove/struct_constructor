# StructConstructor

StructConstructor allows you to declare structs using Ecto.Schema and generate
constructor functions that will take care of coercion and handling various input
formats (maps, keyword lists with string or atom keys).

Documentation can be found at [https://hexdocs.pm/struct_constructor](https://hexdocs.pm/struct_constructor).

## Installation

Add `struct_constructor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:struct_constructor, "~> 0.1.0"}
  ]
end
```

## Usage

Define a typed structure:

```elixir
defmodule User do
  use StructConstructor do
    field :name, :string
    field :age, :integer
  end
end
```

Initialize your structure with external input:

```elixir
User.new(%{"name" => "Alex", "age" => "27"})
# => %User{age: 27, name: "Alex"}
```

Note, that `:age` attribute was automatically converted to integer.

## License

MIT License, Copyright (c) 2017 SaleMove
