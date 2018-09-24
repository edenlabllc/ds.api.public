#!/bin/sh
# `pwd` should be /opt/digital_signature
APP_NAME="digital_signature"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "Elixir.DigitalSignature.ReleaseTasks" migrate
fi;
