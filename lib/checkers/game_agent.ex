defmodule Checkers.GameAgent do
  use GenServer

  ## Public Interface

  def init(v) do
    {:ok, v}
  end

  def start_link() do
    state0 = %{}
    GenServer.start_link(__MODULE__, state0, name: __MODULE__)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def put(key, val) do
    GenServer.call(__MODULE__, {:put, key, val})
  end

  def keys do
    GenServer.call(__MODULE__, {:keys})
  end

  def list do
    GenServer.call(__MODULE__, {:list})
  end

  ## Process Implementation

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:put, key, val}, _from, state) do
    {:reply, :ok, Map.put(state, key, val)}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:list}, _from, state) do
    {:reply, Map.values(state), state}
  end

end