#!/bin/sh
# `pwd` should be /opt/report

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/ds_api command Elixir.API.ReleaseTasks migrate
fi;

APP_NAME="ocsp_service"
if [ "${KAFKA_MIGRATE}" == "true" ] && [ -f "./bin/${APP_NAME}" ]; then
  echo "[WARNING] Migrating kafka topics!"
  ./bin/$APP_NAME command  Elixir.Core.KafkaTasks migrate
fi;
