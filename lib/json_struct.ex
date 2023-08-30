defmodule JsonStruct do
  @moduledoc """
  Documentation for `JsonStruct`.
  """
  defmacro __using__(_opts) do
    quote do
      import JsonStruct, only: [json_struct: 1, json_struct: 2]
    end
  end

  defmacro json_struct(opts \\ [], do: block) do
    ast = JsonStruct.__json_struct__(block)

    case opts[:module] do
      nil ->
        (fn () ->
          impl_ast = JsonStruct.__impl_encoder__(__CALLER__.module)
          quote do
            unquote(ast)
            unquote(impl_ast)
          end
        end).()

      module ->
        impl_ast = JsonStruct.__impl_encoder__(module)
        quote do
          defmodule unquote(module) do
            unquote(ast)
          end
          unquote(impl_ast)
        end
    end
  end

  defmacro field(name, opts \\ []) do
    json_name = Keyword.get(opts, :json, Atom.to_string(name))
    encoder = Macro.escape(Keyword.get(opts,:encode, &Function.identity/1))
    decoder = Macro.escape(Keyword.get(opts,:decode, &Function.identity/1))
    optional = Keyword.get(opts, :optional, false)

    quote bind_quoted: [name: name, optional: optional, json_name: json_name, encoder: encoder, decoder: decoder] do
      @json_struct_fields name
      @json_keys json_name
      @json_optional_fields name

      defp field_to_key_value(unquote(name), value) do
        {unquote(json_name), unquote(encoder).(value)}
      end

      defp key_value_to_field(unquote(json_name), value) do
        {unquote(name), unquote(decoder).(value)}
      end

      defp omit_empty({unquote(name), v}) when is_nil(v), do: unquote(optional)
    end
  end

  def __json_struct__(block) do
    quote do
      import JsonStruct
      Module.register_attribute(__MODULE__, :json_keys, accumulate: true)
      Module.register_attribute(__MODULE__, :json_struct_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :json_optional_fields, accumulate: true)

      unquote(block)

      defstruct @json_struct_fields

      def from_string_map(value) do
        attrs =
          for {k, v} when k in @json_keys <- value do
            key_value_to_field(k, v)
          end

        struct(__MODULE__, attrs)
      end

      def to_string_map(value) do
        values =
          value
          |> Map.from_struct()
          |> Enum.reject(&omit_empty(&1))

        for {k, v} <- values, into: %{} do
          field_to_key_value(k, v)
        end
      end

      defp omit_empty(_), do: false
    end
  end

  def __impl_encoder__(module) do
    quote do
      defimpl Jason.Encoder, for: unquote(module) do
        def encode(value, opts) do
          value
          |> unquote(module).to_string_map()
          |> Jason.Encode.map(opts)
        end
      end
    end
  end
end
