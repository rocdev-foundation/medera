#!/bin/bash

echo "Launching minion"
./scripts/start_minion.sh minion@localhost medera@localhost >& minion.log &

echo "Running tests"
elixir --cookie medera --sname medera@localhost -S mix test
test_result=$?

echo "Stopping minion"
./scripts/stop_minion.sh minion@localhost

exit ${test_result}
