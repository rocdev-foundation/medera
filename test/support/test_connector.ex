defmodule Medera.Support.TestConnector do
  @moduledoc """
  Slack bot interface for testing.

  We mostly just use this to intercept messages that were being sent
  back to slack.

  Note that if possible the event handler should return a synchronous reply
  so that the code can be tested functionally.  This is not always possible,
  so use `await_sent_messages/1` to wait for at least n messages (since the
  messaging is asynchronous).
  """

  defmodule State do
    @moduledoc false
    defstruct([
      token: nil,
      sent_messages: []
    ])
    @type t :: %__MODULE__{}
  end 

  use GenServer

  @doc "Supervisor start callback"
  @spec start_link(binary) :: GenServer.on_start
  def start_link(token) do
    GenServer.start_link(
      __MODULE__,
      {token},
      name: __MODULE__
    )
  end

  @doc "Returns all messages sent so far"
  @spec sent_messages() :: [map]
  def sent_messages do
    GenServer.call(__MODULE__, :sent_messages)
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
    GenServer.call(__MODULE__, :flush)
  end
 
  def init({token}) do
    {:ok, %State{token: token}}
  end

  def handle_call(:sent_messages, _from, state) do
    {:reply, state.sent_messages, state}
  end
  def handle_call(:flush, _from, state) do
    {:reply, :ok, %{state | sent_messages: []}}
  end

  def handle_info({:send_message, text, channel}, state) do
    {:noreply, %{state | sent_messages: [{text, channel}] ++ state.sent_messages}}
  end
end
