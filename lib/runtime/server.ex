defmodule Cacha.Runtime.Server do
  @me __MODULE__

  use Agent

  def start(_type, _args) do
    Agent.start_link(&init/0, name: @me)
  end

  def start_link(_) do
    Agent.start_link(&init/0, name: @me)
  end

  @spec init() :: {:ok, pid}
  def init(), do: %{}

  @spec set(String.t(), any) :: :ok | :error
  def set(key, value) when is_atom(key) or is_binary(key) do
    Agent.update(@me, fn state -> Map.put(state, key, value) end)
  end

  def set(_key, _value), do: :error

  @spec get(String.t()) :: any
  def get(key) when is_atom(key) or is_binary(key) do
    Agent.get(@me, fn state -> Map.get(state, key) end)
  end

  # we could let this fall in the match above but better to handle this client-side.
  def get(_key), do: nil

  @spec del(String.t()) :: :ok
  def del(key) when is_atom(key) or is_binary(key) do
    Agent.update(@me, fn state -> Map.delete(state, key) end)
  end

  # we could let this fall in the match above but better to handle this client-side.
  def del(_key), do: nil

  @spec incr(String.t()) :: {:ok, integer} | {:error, String.t()}
  def incr(key) do
    Agent.get_and_update(@me, fn
      state ->
        Map.get_and_update(state, key, fn
          nil -> {{:ok, 1}, 1}
          value when is_integer(value) -> {{:ok, value + 1}, value + 1}
          _value -> {{:error, "value is not an integer"}, state}
        end)
    end)
  end

  @spec flush_all() :: :ok | :error
  def flush_all do
    Agent.update(@me, fn _ -> %{} end)
  end
end
