defmodule Medera do
  @moduledoc ""
  use Application

  alias Medera.Connector
  alias Medera.MessageProducer
  alias Medera.Printer

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    token = Application.get_env(:medera, :slack_api_token)
    unless token do
      raise "Must specify a value for SLACK_API_TOKEN"
    end

    # Define workers and child supervisors to be supervised
    children = [
      worker(MessageProducer, []),
      worker(Printer, [], id: 1),
      worker(Printer, [], id: 2),
      worker(Connector, [token])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Medera.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
