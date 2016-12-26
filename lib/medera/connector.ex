defmodule Medera.Connector do
  @moduledoc ""
  alias Slack.Bot
  alias Medera.SlackHandler

  def start_link(token) do
    Bot.start_link(SlackHandler, [], token, %{name: __MODULE__})
  end
end
