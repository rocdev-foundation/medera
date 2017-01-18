defmodule Medera.Slack.Supervisor do
  # supervises slack-related processes - these should be tied together
  #  so that restarts are cascading
  @moduledoc false

  use Supervisor

  @doc false
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  @doc false
  def init([]) do
    # get the API token - this MUST be set to some value
    #   (though the value is not used during test)
    token = Application.get_env(:medera, :slack_api_token)
    unless token do
      raise "Must specify a value for SLACK_API_TOKEN"
    end

    # the connector module handles communication with Slack and
    # is different during test
    connector = Application.get_env(:medera, :connector)

    children = [
      worker(connector, [token]),
      worker(Medera.Slack, [connector]),
    ]

    ## note use one_for_all here so both processes restart in unison
    supervise(children, strategy: :one_for_all)
  end
end
