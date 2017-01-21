#!/bin/bash

MEDERA_MASTER=$2 MEDERA_MINION=true elixir --cookie medera --sname $1 -S mix minion.start
