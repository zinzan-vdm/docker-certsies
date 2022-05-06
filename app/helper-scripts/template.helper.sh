template() {
  set +e

  local line
  local lineEscaped

  while IFS= read -r line || [[ -n $line ]]; do
    IFS= read -r -d '' lineEscaped < <(printf %s "$line" | tr '`([$' '\1\2\3\4')
    lineEscaped=${lineEscaped//$'\4'{/\${}
    lineEscaped=${lineEscaped//\"/\\\"}
    eval "printf '%s\n' \"$lineEscaped\"" | tr '\1\2\3\4' '`([$'
  done

  set -e
}

template-file() {
  set +e

  TEMPLATE_PATH="$1"
  VALUES_PATH="$2"

  if [ ! -f "$TEMPLATE_PATH" ]; then
    echo 'Requires at least 1 input providing a path to the template file.';
    exit 1
  fi

  [[ -f "$VALUES_PATH" ]] && source "$VALUES_PATH" 

  set -e

  cat "$TEMPLATE_PATH" | template | cat
}
