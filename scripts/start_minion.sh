#!/bin/bash

if [ "$#" -ne 2 ]
then
  echo "Usage: ./scripts/start_minion.sh MINION_NODE MASTER_NODE"
  echo "    example: ./scripts/start_minion.sh minion@localhost medera@localhost"
  exit 1
fi

MEDERA_MASTER=$2 MEDERA_MINION=true elixir --cookie medera --sname $1 -S mix minion.start
