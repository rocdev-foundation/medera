# Medera

[![Coverage Status](https://coveralls.io/repos/github/585-software/medera/badge.svg?branch=master)](https://coveralls.io/github/585-software/medera?branch=master)

Medera is a [Slack](https://slack.com) bot with _life goals_.

Medera is a project of the Rochester, NY,
[functional programming user group](https://www.meetup.com/%CE%BB-Rochester-Functional-Programming-Language-Meetup/).

## Basic architecture

A Medera installation constists of two components:

1. Medera master node - A single (for now) node that connects to Slack and
   provides a web front-end.
2. Medera minions - One or more Elixir nodes that connect to the master.  The
   master node is also a minion.

## Slack commands

### "Hi"

Hello, world!

### ["I am error"](https://en.wikipedia.org/wiki/I_am_Error)

Used for internal error testing.

### "!list-minions"

Prints a list of connected minion nodes.

### "!list-skills node@host"

Lists the skills available from the minion `node@host`

### "!get-minion-info node@host"

Gets some information about the minion `node@host`.

### Skills from JSON

Skills can be loaded from a JSON file.  The format is as follows.

```
[
  {
    "description": "A brief description of what this skill does",
    "verb": "do",
    "noun": "thing",
    "command": "/bin/cat /some/file.txt"
  }
]
```

When minion `node@host` loads this skill, it can be executed from Slack by the
_invocation_ `do-thing node@host` (`verb-noun nodename@nodehost`).  The skills
JSON file can be specified when running a minion via the `MINION_SKILLS`
environment variable.

Note, the master node may also be provided with a skills file.

## Running Medera

**Requirements**:  Elixir, Postgres, and a Slack API token.

To run the master node in interactive mode:

## Basic architecture

A Medera installation constists of two components:

1. Medera master node - A single (for now) node that connects to Slack and
   provides a web front-end.
2. Medera minions - One or more Elixir nodes that connect to the master.  The
   master node is also a minion.

## Slack commands

### "Hi"

Hello, world!

### ["I am error"](https://en.wikipedia.org/wiki/I_am_Error)

Used for internal error testing.

### "!list-minions"

Prints a list of connected minion nodes.

## Running Medera

**Requirements**:  Elixir, Postgres, and a Slack API token.

To run the master node in interactive mode:

```
mix deps.get
SLACK_API_TOKEN=xoxb-000000000000-000000000000000000000000 MINION_SKILLS=./test/fixture/skills/master_test_skills.json iex --cookie medera --sname medera@localhost -S mix phoenix.server
```

To run a minion interactively:

```
MINION_SKILLS=./test/fixture/skills/test_skills.json MEDERA_MASTER=medera@localhost MEDERA_MINION=true iex --cookie medera --sname minion@localhost -S mix
```

To run a minion in the background:

```
./scripts/start_minion.sh minion@localhost medera@localhost ./test/fixtures/skills/test_skills.json >& minion.log &
```

To stop a minion:

```
./scripts/stop_minion.sh minion@localhost
```

## Development

Contributions are welcome!  Before contributing, make sure that your code is
tested, all tests pass, dialyzer does not return any warnings or errors, and
credo does not return any warnings.

### Testing

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

### Dialyzer

To run static type analysis with
[dialyzer](http://erlang.org/doc/man/dialyzer.html):

```
mix dialyzer
```

### Credo

To run static code quality analysis with
[credo](https://github.com/rrrene/credo):

```
mix credo --strict
```
