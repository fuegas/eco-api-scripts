#!/bin/bash

set -o errexit

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${script_path}/lib/common.sh"

# Build URLs
url_base="http://${server}"
url_stores="${url_base}/api/v1/plugins/EcoPriceCalculator/stores"
url_recipes="${url_base}/api/mods/v1/recipes"
url_tags="${url_base}/api/v1/plugins/EcoPriceCalculator/tags"

# Inform which URL we're querying
info "Using base URL: ${url_base}"
info "Stores: ${url_stores}"
info "Recipes: ${url_recipes}"
info "Tags: ${url_tags}"

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
