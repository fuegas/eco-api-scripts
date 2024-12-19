#!/bin/bash

  # --dry-run --itemize-changes \
rsync -a \
  --verbose \
  --exclude='archive/*' \
  --exclude='deploy.sh' \
  --exclude='recipes/*.html' \
  --exclude='tmp/creds.txt' \
  --exclude='tmp/*.json' \
  ./* \
  ./.ruby-version \
  naka:~/eco-stats/
