#!/bin/bash

# launches a minion, runs the tests, then stops the minion
# the exit code of this script should be the exit code of the tests

TEST_TASK=${TEST_TASK:-test}
export MIX_ENV=test

echo "Launching minion"
./scripts/start_minion.sh minion@localhost medera@localhost >& minion.log &

echo "Running tests"
elixir --cookie medera --sname medera@localhost -S mix ${TEST_TASK}
test_result=$?

echo "Stopping minion"
./scripts/stop_minion.sh minion@localhost

exit ${test_result}
