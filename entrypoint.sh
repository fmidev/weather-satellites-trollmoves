#!/usr/bin/bash

_term() {
  echo "Entrypoint caught SIGTERM signal"
  kill -TERM "$child" 2>/dev/null
  echo "Waiting for child process to exit"
  wait "$child"
}

trap _term SIGTERM

source /opt/conda/.bashrc
source /config/env-variables

micromamba activate
if [ -e /config/trollmoves_server.ini ]; then
    /opt/conda/bin/move_it_server.py -c /config/trollmoves_log_config.yaml -p 40000 ${DISABLE_BACKLOG} ${USE_WATCHDOG} /config/trollmoves_server.ini &
    child=$!
elif [ -e /config/trollmoves_client.ini ]; then
    /opt/conda/bin/move_it_client.py -c /config/trollmoves_log_config.yaml /config/trollmoves_client.ini &
    child=$!
fi

wait "$child"
