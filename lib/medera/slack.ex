defmodule Medera.Slack do
  @moduledoc """
  Medera's adapter for dealing with slack.

  The slack bot code is very hard to test; this module acts as an adapter
  between the slack connection and our handlers and message sends.

  Furthermore, this module separates the slack bot from our work, which will
  allow us to build a work pool in the future if necessary.

  The only public function you should need to use here is `send_message/2` and
  even that should only be used if a synchronous response is impossible
  (see `Medera.Slack.Handler.handle_event/1`).
  """

  defmodule State do
    @moduledoc false
    # internal state for slack adapter
    defstruct(connector: nil)
  end

  use GenServer
  require Logger

  alias Medera.Slack.Event
  alias Medera.Slack.Handler

  @doc """
  Send a message to a slack channel

  Use this only for asynchronous messages if possible.
  See `Medera.Slack.Handler.handle_event/1`
  """
  @spec send_message(binary, binary) :: :ok
  def send_message(text, channel) do
    GenServer.call(__MODULE__, {:send_message, text, channel})
  end

  @doc false
  @spec start_link(binary) :: GenServer.on_start
  def start_link(connector) do
    GenServer.start_link(__MODULE__, {connector}, name: __MODULE__)
  end

  # should only be used in tests to simulate receiving a message
  @doc false
  @spec receive_event(Event.t | {Event.t, map}) :: :ok
  def receive_event(event = %Event{}) do
    GenServer.call(__MODULE__, {:receive_event, event})
  end
  def receive_event({event, extra}) do
    receive_event(Event.from_slack(event, extra))
  end

  @doc false
  @spec receive_event(map, map) :: :ok
  def receive_event(event = %{}, extra \\ %{}) when is_map(extra) do
    receive_event({event, extra})
  end

  ######################################################################
  # GenServer callbacks

  @doc false
  def init({connector}) do
    {:ok, %State{connector: connector}}
  end

  @doc false
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

  ######################################################################
  # Implementation

  defp do_send(connector, text, channel) do
    send(connector, {:send_message, text, channel})
  end

  defp handle_event_side_effects(:ok, _, _), do: :ok
  defp handle_event_side_effects({:error, error}, source_event, _) do
    # eventually we may want to handle errors
    Logger.error(
      "Error: #{inspect error} encountered while handling " <>
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
