#!/bin/bash

  # --dry-run \
rsync -a \
  --verbose \
  --exclude='deploy.sh' \
  --exclude='tmp/creds.txt' \
  --exclude='tmp/*.json' \
  ./* \
  ./.ruby-version \
  naka:~/eco-stats/
