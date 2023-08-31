# JsonStruct

<!-- @moduledoc -->

JsonStruct is a elixir library that takes care of implementing the Jason.Encoder Protocol for a
struct.

It also allows for easy renaming of keys and gives you the option to add your own
encoding/decoding function for each field.

```elixir
defmodule Message do
  use JsonStruct

  json_struct do
    field :to, json: "to"
    field :id, json: "msgId"

    field :message,
      json: "msg",
      encode: &String.upcase/1,
      decode: &String.downcase/1
  end
end
msg = %Message{id: "abcd", to: "José", message: "I love Elixir!"} |> Jason.encode!()
msg == ~s|{"msg":"I LOVE ELIXIR!","msgId":"abcd","to":"José"}|
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `json_struct` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:json_struct, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/json_struct>.

