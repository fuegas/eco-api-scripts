#!/bin/bash

set -o errexit

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${script_path}/lib/common.sh"

# Only rebuild cache when server has been up > 5 minutes
#
# When the server just restarted, we receive incorrect data from the API.
# So we need to wait a few minutes for the server to settle down.
status_path="${tmp_path}/${server}.status"

up_since="0"
if [ -f "${status_path}" ]; then
  up_since=$(cat "${status_path}")
fi

if [[ "${up_since}" -eq 0 ]]; then
  info "${status_path} does not exist or reports server is down. Not rebuilding cache."
  exit 0
fi

timestamp=$(date +%s)
if [ $(( timestamp - up_since )) -le 300 ]; then
  info 'Server uptime < 5 minutes. Not rebuilding cache.'
  exit 0
else
  info 'Server uptime > 5 minutes. Rebuilding cache.'
fi

# Build URLs
url_base="http://${server}"
url_info="${url_base}/info"
url_stores="${url_base}/api/v1/plugins/EcoPriceCalculator/stores"
url_recipes="${url_base}/api/mods/v1/recipes"
url_tags="${url_base}/api/v1/plugins/EcoPriceCalculator/tags"

# Inform which URL we're querying
info "Using base URL: ${url_base}"
info "Info: ${url_info}"
info "Stores: ${url_stores}"
info "Recipes: ${url_recipes}"
info "Tags: ${url_tags}"

# Server info
info 'Downloading info'
curl \
  ${curl_opts} \
  --fail \
  --output ${tmp_path}/info.tmp \
  ${url_info} \
  && mv ${tmp_path}/info.tmp ${tmp_path}/info.json \
  && (cat ${tmp_path}/info.json | jq . > ${tmp_path}/info-pretty.json)

# Download orders
info 'Downloading stores'
curl \
  ${curl_opts} \
  --fail \
  --output ${tmp_path}/stores.tmp \
  ${url_stores} \
  && mv ${tmp_path}/stores.tmp ${tmp_path}/stores.json \
  && (cat ${tmp_path}/stores.json | jq . > ${tmp_path}/stores-pretty.json)

# Recipes / tags
info 'Downloading recipes'
curl \
  ${curl_opts} \
  --fail \
  --output ${tmp_path}/recipes.tmp \
  ${url_recipes} \
  && mv ${tmp_path}/recipes.tmp ${tmp_path}/recipes.json \
  && (cat ${tmp_path}/recipes.json | jq . > ${tmp_path}/recipes-pretty.json)

info 'Downloading tags'
curl \
  ${curl_opts} \
  --fail \
  --output ${tmp_path}/tags.tmp \
  ${url_tags} \
  && mv ${tmp_path}/tags.tmp ${tmp_path}/tags.json \
  && (cat ${tmp_path}/tags.json | jq . > ${tmp_path}/tags-pretty.json)
