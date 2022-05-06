#!/bin/bash

# See: https://github.com/dehydrated-io/dehydrated/issues/270
# See: https://github.com/kousu/dehydrated-hooks/blob/trunk/hooks.sh

run-parts() {
  # a replacement for run-parts(8)
  # that supports passing arguments
  # (run-parts supports this but demands they are passed individually, which is not compatible with the "$@" special-case for writing wrapper scripts)
  # usage: run-parts DIRECTORY [arg... ]

  # TODO: support --verbose; requires getting getopts out I guess.

  dir="$1"; shift
  if [ -d "$dir" ]; then
    ls -1 "${dir}" | sort | while read prog; do
      if [ -x "${dir}/${prog}" ]; then
        echo "Running ${dir}/${prog}"
        "${dir}/${prog}" "$@"
      fi
    done
  fi
}

echo "Executing app hooks with ($@)."
run-parts /app/hooks/hooks.d "$@"

if [[ -d /certsies/hooks ]]; then
  echo "Executing custom hooks with ($@)."
  run-parts /certsies/hooks "$@"
fi
