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
    children = child_specs(Application.get_env(:medera, :web_enabled))

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

  def child_specs(true) do
    slack_children() ++ web_children() ++ minion_children()
  end
  def child_specs(_) do
    minion_children()
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

  defp minion_children do
    [
      supervisor(Medera.Minion, [])
    ]
  end
end
