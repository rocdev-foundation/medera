defmodule Medera do
  @moduledoc """
  This is the main [OTP Application](https://hexdocs.pm/elixir/Application.html)
  callback module for the application.

  The most important function here is `start/2`, which starts a supervisor.
  """

  use Application

  alias Medera.Endpoint

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # get the API token - this MUST be set to some value
    #   (though the value is not used during test)
    token = Application.get_env(:medera, :slack_api_token)
    unless token do
      raise "Must specify a value for SLACK_API_TOKEN"
    end

    # the connector module handles communication with Slack and
    # is different during test
    connector = Application.get_env(:medera, :connector)

    # Define workers and child supervisors to be supervised
    children = [
      # TODO these should go on their own supervisor with one-for-one
      worker(connector, [token]),
      worker(Medera.Slack, [connector]),
      # Start the Ecto repository
      supervisor(Medera.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Medera.Endpoint, []),
      # Start your own worker by calling:
      # Medera.Worker.start_link(arg1, arg2, arg3)
      # worker(Medera.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Medera.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
