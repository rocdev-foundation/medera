# Medera

[![Coverage Status](https://coveralls.io/repos/github/585-software/medera/badge.svg?branch=master)](https://coveralls.io/github/585-software/medera?branch=master)

Simple Slack bot that responds to "Hi" with "Hello, there!"
All other event types and messages are ignored.

To run this, install Elixir and get a Slack API token.

To run the master node:

```
brew install elixir
docker run --name pg -p 5432:5432 -d -e "POSTGRES_USER=postgres" -e "POSTGRES_PASSWORD=postgres" -e "POSTGRES_DB=medera_dev" postgres:9.6
mix deps.get
SLACK_API_TOKEN=xoxb-000000000000-000000000000000000000000 iex --cookie medera --sname medera@localhost -S mix phoenix.server
```

To run a minion interactively:

```
MEDERA_MASTER=medera@localhost MEDERA_MINION=true iex --cookie medera --sname minion@localhost -S mix
```

To run a minion in the background:

```
./scripts/start_minion.sh minion@localhost medera@localhost >& minion.log &
```

To stop a minion:

```
./scripts/stop_minion.sh minion@localhost
```

## Tests

The tests assume that a postgres database can be created with the name
"medera_test" - either via docker or a local postgres installation.

The tests also require a minion node to be running with the name
`minion@localhost`.

To automate running the tests:

```
./scripts/run_tests.sh
```

Or, if you want to see a coverage report:

```
TEST_TASK=coveralls.html ./scripts/run_tests.sh
```

## Dialyzer

To run static type analysis with
[dialyzer](http://erlang.org/doc/man/dialyzer.html):

```
mix dialyzer
```

