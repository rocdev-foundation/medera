# SlackIngestor

Simple Slack bot that responds to "Hi" with "Hello to you, too!"
All other event types and messages are ignored.

To run this, install Elixir and get a Slack API token.

```
brew install elixir
mix deps.get
SLACK_API_TOKEN=xoxb-000000000000-000000000000000000000000 iex -S mix
```
