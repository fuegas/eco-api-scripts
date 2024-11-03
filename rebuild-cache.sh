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

# Download orders
$terminal && echo 'Downloading buy orders'
curl \
  --fail \
  ${curl_opts} \
  --output ${tmp_path}/orders-buy.tmp \
  'http://135.148.150.86:3001/elixr-mods/framework/api/v1/get-prices/false' \
  && mv ${tmp_path}/orders-buy.tmp ${tmp_path}/orders-buy.json \
  && (cat ${tmp_path}/orders-buy.json | jq . > ${tmp_path}/orders-buy-pretty.json)

$terminal && echo 'Downloading sell orders'
curl \
  --fail \
  --output ${tmp_path}/orders-sell.tmp \
  'http://135.148.150.86:3001/elixr-mods/framework/api/v1/get-prices/true' \
  && mv ${tmp_path}/orders-sell.tmp ${tmp_path}/orders-sell.json \
  && (cat ${tmp_path}/orders-sell.json | jq . > ${tmp_path}/orders-sell-pretty.json)

# Create a readable format for debugging
# $terminal && echo 'Make output pretty'
# cat ${tmp_path}/orders-buy.json \
#   | jq . > ${tmp_path}/orders-buy-pretty.json
# cat ${tmp_path}/orders-sell.json \
#   | jq . > ${tmp_path}/orders-sell-pretty.json
