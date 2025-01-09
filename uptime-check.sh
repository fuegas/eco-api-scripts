#!/usr/bin/env bash

set -u

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${script_path}/lib/common.sh"

up_since="0"
if [ -f "${status_path}" ]; then
  up_since=$(cat "${status_path}")
fi

url="http://${server}/info"
info "Checking uptime using ${url}"

curl \
  ${curl_opts} \
  --fail \
  --no-progress-meter \
  --output /dev/null \
  --connect-timeout 2 \
  --max-time 2 \
  "${url}"
retval=$?

if [[ "${retval}" -eq 0 ]]; then
  if [[ "${up_since}" -eq 0 ]]; then
    timestamp=$(date +%s)
    echo "${timestamp}" > "${status_path}"
    echo "  up since $(date)" >> "${tmp_path}/${server}.log"
  fi
else
  echo "0" > "${status_path}"
  if ! [[ "${up_since}" -eq 0 ]]; then
    echo "down since $(date)" >> "${tmp_path}/${server}.log"
  fi
fi
