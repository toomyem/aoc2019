#!/bin/bash

set -euo pipefail
shopt -s extglob

day=$(basename "$(pwd)")
nr=${day/day*(0)}
input=puzzle.input

[[ -s "$input" ]] || wget -O "$input" --header "Cookie: session=${SESSION:?is not set}" "https://adventofcode.com/2019/day/$nr/input"

[[ "$#" -gt 0 ]] && input="$1"

if [[ "$input" = "-" ]]
then
  gleam run --no-print-progress
else
  gleam run --no-print-progress < "$input"
fi
