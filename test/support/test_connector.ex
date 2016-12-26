defmodule Medera.Support.TestConnector do
  defmodule State do
    defstruct token: nil
  end 

  def start_link(token) do
    Agent.start_link(fn -> %State{token: token} end)
  end
end
