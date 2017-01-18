# Medera

Simple Slack bot that responds to "Hi" with "Hello, there!"
All other event types and messages are ignored.

To run this, install Elixir and get a Slack API token.

```
brew install elixir
docker run --name pg -p 5432:5432 -d -e "POSTGRES_USER=postgres" -e "POSTGRES_PASSWORD=postgres" -e "POSTGRES_DB=medera_dev" postgres:9.6
mix deps.get
SLACK_API_TOKEN=xoxb-000000000000-000000000000000000000000 iex -S mix
```

## Tests

The tests assume that a postgres database can be created with the name
"medera_test" - either via docker or a local postgres installation.  If that is
set up, then just run

```
mix test
```

Or, if you want to see a coverage report:

```
mix test --cover # text report
# or
MIX_ENV=test mix coveralls.html # generates cover/index.html
```

## Dialyzer

To run static type analysis with
[dialyzer](http://erlang.org/doc/man/dialyzer.html):

```
mix dialyzer
```

