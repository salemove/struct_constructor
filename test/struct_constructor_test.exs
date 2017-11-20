defmodule StructConstructorTest do
  use ExUnit.Case, async: true

  defmodule User do
    use StructConstructor do
      field :name, :string
      field :age, :integer
      field :timestamp, :utc_datetime
      field :status, :string, virtual: true
    end

    def after_load(user),
        do: %{user | status: :loaded}
  end

  defmodule StructWithEmbed do
    use StructConstructor do
      field :id, :integer
      embeds_one :user, User
      embeds_one :inline, Inline do
        field :name, :string
      end
    end
  end

  defmodule StructWithEmbedMany do
    use StructConstructor do
      field :id, :integer
      embeds_one :user, User
      embeds_many :inline, Inline do
        field :name, :string
      end
    end
  end

  @timestamp %DateTime{year: 2017, month: 4, day: 22,
    hour: 4, minute: 4, second: 4, microsecond: {0, 0},
    utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC", zone_abbr: "UTC"}

  test "initializes struct from kwlist" do
    user = User.new(name: "Alex", age: "27", timestamp: DateTime.to_iso8601(@timestamp))

    assert user.name == "Alex"
    assert user.age == 27
    assert user.timestamp == @timestamp
    assert user.status == :loaded
  end

  test "initializes struct from map" do
    user = User.new(%{"name" => "Alex", "age" => "27", "timestamp" => DateTime.to_iso8601(@timestamp)})

    assert user.name == "Alex"
    assert user.age == 27
    assert user.timestamp == @timestamp
    assert user.status == :loaded
  end

  test "supports embed_one schemas" do
    struct = StructWithEmbed.new(
      id: 123,
      user: %{name: "Alex", age: 27, timestamp: DateTime.to_iso8601(@timestamp)},
      inline: %{name: "Dan"}
    )

    assert struct.id == 123
    assert struct.user == %User{name: "Alex", age: 27, timestamp: @timestamp, status: :loaded}
    assert struct.inline == %StructWithEmbed.Inline{name: "Dan"}
  end

  test "supports embed_many schemas" do
    struct = StructWithEmbedMany.new(
      id: 123,
      user: %{name: "Alex", age: 27, timestamp: DateTime.to_iso8601(@timestamp)},
      inline: [%{name: "Dan"}]
    )

    assert struct.id == 123
    assert struct.user == %User{name: "Alex", age: 27, timestamp: @timestamp, status: :loaded}
    assert struct.inline == [%StructWithEmbedMany.Inline{name: "Dan"}]
  end
end
