#!/bin/sh
# `pwd` should be /opt/report

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/ds_api command Elixir.API.ReleaseTasks migrate
fi;
