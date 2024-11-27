#!/usr/bin/bash

source /opt/conda/.bashrc
source /config/env-variables

micromamba activate
if [ -e /config/trollmoves_server.ini ]; then
    /opt/conda/bin/move_it_server.py -c /config/trollmoves_log_config.yaml -p 40000 ${DISABLE_BACKLOG} ${USE_WATCHDOG} /config/trollmoves_server.ini
elif [ -e /config/trollmoves_client.ini ]; then
    /opt/conda/bin/move_it_client.py -c /config/trollmoves_log_config.yaml /config/trollmoves_client.ini
fi
