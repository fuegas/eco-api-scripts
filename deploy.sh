#!/bin/bash

  # --dry-run \
rsync -a \
  --dry-run \
  --verbose \
  --exclude='tmp/creds.txt' \
  --exclude='tmp/*.json' \
  ./* \
  ./.ruby-version \
  naka:~/eco-stats/
