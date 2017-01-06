defmodule Medera.Support.TestConnector do
  @moduledoc """
  Doubles for the Slack bot (Medera.Connector) for testing
  """

  defmodule State do
    @moduledoc false
    defstruct([
      token: nil,
      sent_messages: []
    ])
    @type t :: %__MODULE__{}
  end 

  alias Medera.SlackEventHandler

  @doc "Supervisor start callback"
  @spec start_link(binary) :: Agent.on_start
  def start_link(token) do
    Agent.start_link(
      fn -> %State{token: token} end,
      name: __MODULE__
    )
  end

  @doc "Simulate receiving a message"
  @spec receive_message(binary, binary) :: :ok
  def receive_message(text, channel) do
    message = %{text: text, channel: channel, type: "message"}
    Agent.get(__MODULE__, fn(_state) ->
      SlackEventHandler.handle_event(message)
    end)
  end

  @doc "Returns all messages sent so far"
  @spec sent_messages() :: [map]
  def sent_messages do
    Agent.get(__MODULE__, fn(state) -> state.sent_messages end)
  end

  # do not call this manually - it gets called as a callback when we
  #  send a message to slack in test mode
  @doc false
  def send_message(text, channel) do
    Agent.update(__MODULE__, fn(state) ->
      message = %{text: text, channel: channel, type: "message"}
      %{
        state |
        sent_messages: [message] ++ state.sent_messages
       }
    end)
  end

  @doc """
  Return all messages sent so far, synchronously waiting until at least n
  are available

  This allows us to test the results of asynchronous behavior
  """
  @spec await_sent_messages(non_neg_integer) :: [map]
  def await_sent_messages(n) do
    Patiently.wait_for!(fn -> length(sent_messages) >= n end)
    sent_messages
  end

  @doc "Reset sent messages buffer"
  @spec flush_sent_messages() :: :ok
  def flush_sent_messages do
    Agent.update(__MODULE__, fn(state) -> %{state | sent_messages: []} end)
  end

  @doc false
  def cast(pid, {:text, json}) do
    Agent.update(pid, fn(state) ->
      %{
        state |
        sent_messages: [JSX.decode!(json, labels: :atom)] ++ state.sent_messages
       }
    end)
  end
end
