defmodule Medera.Slack do
  defmodule State do
    @moduledoc false
    # internal state for slack adapter
    defstruct(connector: nil)
  end

  require Logger

  alias Medera.Slack.Event
  alias Medera.Slack.Handler

  def start_link(connector) do
    GenServer.start_link(__MODULE__, {connector}, name: __MODULE__)
  end

  def receive_event(event = %Event{}) do
    GenServer.call(__MODULE__, {:receive_event, event})
  end
  def receive_event(event = %{}) do
    receive_event(Event.from_slack(event))
  end

  def send_message(text, channel) do
    GenServer.call(__MODULE__, {:send_message, text, channel})
  end

  def init({connector}) do
    {:ok, %State{connector: connector}}
  end

  def handle_call({:receive_event, event}, _from, state) do
    event
    |> Handler.handle_event
    |> handle_event_side_effects(event, state)

    {:reply, :ok, state}
  end
  def handle_call({:send_message, text, channel}, _from, state) do
    do_send(state.connector, text, channel)
    {:reply, :ok, state}
  end

  defp do_send(connector, text, channel) do
    send(connector, {:send_message, text, channel})
  end

  defp handle_event_side_effects(:ok, _, _), do: :ok
  defp handle_event_side_effects({:error, error}, source_event, _) do
    # TODO handle errors
    Logger.error(
      "Error: #{inspect error} encountered while handling" <> 
      "event #{inspect source_event}"
    )
    :ok
  end
  defp handle_event_side_effects(
    {:ok, {:reply, text, to_channel}},
    _,
    state
  ) do
    do_send(state.connector, text, to_channel)
    :ok
  end
end
