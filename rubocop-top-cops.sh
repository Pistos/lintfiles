#!/bin/sh

N="${1:-20}"

rubocop --format json 2>/dev/null \
  | jq -r \
    --argjson n "$N" \
    '[.files[].offenses[].cop_name]
    | group_by(.)
    | map({cop: .[0], count: length})
    | sort_by(-.count)
    | .[:$n][]
    | "\(.count)\t\(.cop)"'
