#!/bin/bash

if [ "$#" -ne 3 ]
then
  echo "Usage: ./scripts/start_minion.sh MINION_NODE MASTER_NODE MINION_SKILLS"
  echo "    example: ./scripts/start_minion.sh minion@localhost medera@localhost skills.json"
  exit 1
fi

MINION_SKILLS=$3 MEDERA_MASTER=$2 MEDERA_MINION=true elixir --cookie medera --sname $1 -S mix minion.start
