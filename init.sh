#!/bin/bash

set -euo pipefail

if [[ "$#" -eq 0 ]]
then
  echo "Usage: $0 <day>"
  exit 1
fi

day="$1"
day_padded=$(printf "day%02d" "$day")

if [[ -d "$day_padded" ]]
then
  echo "$day_padded already exists"
  exit 0
fi

cp -rv template "$day_padded"
find "$day_padded" -type f -print | while read -r f
do
  sed -i "s/_day_/$day_padded/g" "$f"
  [[ $f == *template.gleam ]] && mv "$f" "$day_padded/src/$day_padded.gleam"
done
