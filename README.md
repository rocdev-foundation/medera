# SlackIngestor

Simple Slack bot that responds to "Hi" with "Hello to you, too!"
All other event types and messages are ignored.

To run this, install Elixir and get a Slack API token.

```
brew install elixir
docker run --name pg -p 5432:5432 -d -e "POSTGRES_USER=postgres" -e "POSTGRES_PASSWORD=postgres" -e "POSTGRES_DB=medera_dev" postgres:9.6
mix deps.get
SLACK_API_TOKEN=xoxb-000000000000-000000000000000000000000 iex -S mix
```
