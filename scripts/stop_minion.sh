#!/bin/bash

elixir --cookie medera --sname minion_killer -S mix minion.stop $1
