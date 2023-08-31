defmodule JsonStructTest do
  use ExUnit.Case
  doctest JsonStruct

  defmodule Message do
    use JsonStruct

    json_struct do
      field :to

      field :content,
        json: "c",
        optional: true,
        encode: &Base.encode64(&1, case: :lower),
        decode: &Base.decode64!(&1, case: :lower)
    end
  end

  test "struct" do
    msg = %Message{to: "Jen", content: "hi"}

    json = Jason.encode!(msg)
    assert ~s|{"c":"aGk=","to":"Jen"}| == json
    assert msg == Jason.decode!(json) |> Message.from_string_map()

    msg = %Message{content: "no name"}

    json = Jason.encode!(msg)
    assert ~s|{"c":"bm8gbmFtZQ==","to":null}| == json
    assert msg == Jason.decode!(json) |> Message.from_string_map()
  end
end
