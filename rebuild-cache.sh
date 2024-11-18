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

# Inform which URL we're querying
if $terminal; then
  echo "Using base URL: ${url_base}"
  echo "Buy orders:  ${url_buy_orders}"
  echo "Sell orders: ${url_sell_orders}"
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
