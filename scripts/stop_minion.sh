#!/bin/bash

if [ "$#" -ne 1 ]
then
  echo "Usage: ./scripts/stop_minion.sh MINION_NODE"
  echo "    example: ./scripts/stop_minion.sh minion@localhost"
  exit 1
fi

elixir --cookie medera --sname brock_samson -S mix minion.stop $1
