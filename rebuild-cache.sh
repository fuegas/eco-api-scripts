#!/bin/bash
set -o errexit

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tmp_path="${script_path}/tmp"
server_ip="135.148.150.86"
server_port="3001"

# Are we running in a terminal?
terminal=false
if [ -t 1 ] ; then
  terminal=true
fi

# Base curl options on terminal state
curl_opts='--silent'
if $terminal; then
  curl_opts='--dump-header /dev/stderr'
fi

# Build URLs
url_base="http://${server_ip}:${server_port}"
url_buy_orders="${url_base}/api/mods/v1/prices?includeOutOfStock=false"
url_sell_orders="${url_base}/api/mods/v1/prices?includeOutOfStock=true"
url_stores="${url_base}/api/v1/plugins/EcoPriceCalculator/stores"
url_laws="${url_base}/api/v1/laws/byStates/Active"
url_recipes="${url_base}/api/mods/v1/recipes"
url_tags="${url_base}/api/v1/plugins/EcoPriceCalculator/tags"

# Inform which URL we're querying
if $terminal; then
  echo "Using base URL: ${url_base}"
  echo "Buy orders:  ${url_buy_orders}"
  echo "Sell orders: ${url_sell_orders}"
  echo "Stores: ${url_stores}"
  echo "Laws: ${url_laws}"
fi

# Download orders
$terminal && echo 'Downloading stores'
curl \
  --fail \
  --output ${tmp_path}/stores.tmp \
  ${url_stores} \
  && mv ${tmp_path}/stores.tmp ${tmp_path}/stores.json \
  && (cat ${tmp_path}/stores.json | jq . > ${tmp_path}/stores-pretty.json)

# $terminal && echo 'Downloading sell orders'
# curl \
#   --fail \
#   --output ${tmp_path}/orders-sell.tmp \
#   ${url_sell_orders} \
#   && mv ${tmp_path}/orders-sell.tmp ${tmp_path}/orders-sell.json \
#   && (cat ${tmp_path}/orders-sell.json | jq . > ${tmp_path}/orders-sell-pretty.json)

# $terminal && echo 'Downloading buy orders'
# curl \
#   --fail \
#   ${curl_opts} \
#   --output ${tmp_path}/orders-buy.tmp \
#   ${url_buy_orders} \
#   && mv ${tmp_path}/orders-buy.tmp ${tmp_path}/orders-buy.json \
#   && (cat ${tmp_path}/orders-buy.json | jq . > ${tmp_path}/orders-buy-pretty.json)

# $terminal && echo 'Downloading laws'
# curl \
#   --fail \
#   --output ${tmp_path}/laws.tmp \
#   ${url_laws} \
#   && mv ${tmp_path}/laws.tmp ${tmp_path}/laws.json \
#   && (cat ${tmp_path}/laws.json | jq . > ${tmp_path}/laws-pretty.json)

# Items

$terminal && echo 'Downloading recipes'
curl \
  --fail \
  --output ${tmp_path}/recipes.tmp \
  ${url_recipes} \
  && mv ${tmp_path}/recipes.tmp ${tmp_path}/recipes.json \
  && (cat ${tmp_path}/recipes.json | jq . > ${tmp_path}/recipes-pretty.json)

$terminal && echo 'Downloading tags'
curl \
  --fail \
  --output ${tmp_path}/tags.tmp \
  ${url_tags} \
  && mv ${tmp_path}/tags.tmp ${tmp_path}/tags.json \
  && (cat ${tmp_path}/tags.json | jq . > ${tmp_path}/tags-pretty.json)
