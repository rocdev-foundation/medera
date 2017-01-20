defmodule Medera do
  @moduledoc """
  This is the main [OTP Application](https://hexdocs.pm/elixir/Application.html)
  callback module for the application.

  The most important function here is `start/2`, which starts a supervisor.
  """

  use Application
  import Supervisor.Spec, warn: false

  alias Medera.Endpoint

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do

    children = if Application.get_env(:medera, :web_enabled) do
      slack_children() ++ web_children() ++ minion_children()
    else
      minion_children()
    end

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

  defp slack_children do
    [
      supervisor(Medera.Slack.Supervisor, []),
    ]
  end

  defp web_children do
    [
      supervisor(Medera.Repo, []),
      supervisor(Medera.Endpoint, [])
    ]
  end

  defp minion_children() do
    [
      supervisor(Medera.Minion, [])
    ]
  end
end
