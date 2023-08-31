defmodule JsonStructTest do
  use ExUnit.Case
  doctest JsonStruct

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

  test "readme example test" do
    msg = %Message{id: "abcd", to: "José", message: "I love Elixir!"} |> Jason.encode!()

    assert msg == ~s|{"msg":"I LOVE ELIXIR!","msgId":"abcd","to":"José"}|
  end

  defmodule MessageBase64 do
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

  test "ensure encoding works" do
    msg = %MessageBase64{to: "Jen", content: "hi"}

    json = Jason.encode!(msg)
    assert ~s|{"c":"aGk=","to":"Jen"}| == json
    assert msg == Jason.decode!(json) |> MessageBase64.from_string_map()

    msg = %MessageBase64{content: "no name"}

    json = Jason.encode!(msg)
    assert ~s|{"c":"bm8gbmFtZQ==","to":null}| == json
    assert msg == Jason.decode!(json) |> MessageBase64.from_string_map()

    msg = %MessageBase64{to: "Someone"}

    json = Jason.encode!(msg)
    assert ~s|{"to":"Someone"}| == json
    assert msg == Jason.decode!(json) |> MessageBase64.from_string_map()
  end
end
