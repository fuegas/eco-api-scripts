# Shared variables
tmp_path="${script_path}/tmp"

# A way to easily write to stderr
function error {
  >&2 echo "$@"
}

# First argument should be the address (with port) of the server
server="${1-}"
if [[ -z "${server}" ]]; then
  error "Server not passed as argument"
  error "Usage: $0 <server ip:port> [flags]"
  exit 1
fi
status_path="${tmp_path}/${server}.status"

# Are we running in a terminal?
terminal=false
if [[ -t 1 ]]; then
  terminal=true
fi

# Do we want debug flags?
debug=false
if [[ "$@" =~ --debug ]]; then
  debug=true
fi

# Base curl options on terminal state
curl_opts='--location'
if ! $terminal; then
  curl_opts="${curl_opts} --silent"
fi
if $debug; then
  curl_opts="${curl_opts} --dump-header /dev/stderr"
fi

# Info will only output if you're running in a terminal
function info {
  if [[ ! ${terminal} ]]; then
    return
  fi

  echo "$@"
}
