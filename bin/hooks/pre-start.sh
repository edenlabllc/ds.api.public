#!/bin/sh
# `pwd` should be /opt/report

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/api command Elixir.API.ReleaseTasks migrate
fi;
