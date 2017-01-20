defmodule Medera.Minion.Listener do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Phoenix.PubSub.subscribe(Medera.Minion.PubSub, "things")
    {:ok, nil}
  end

  def handle_info(info, state) do
    IO.puts("GOT #{inspect info}")
    {:noreply, state}
  end
end
