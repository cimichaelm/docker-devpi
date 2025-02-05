#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function defaults() {
    PORT=3141
    u=devpi
    venv=env
    PREFIX=/
    venvbin=${PREFIX}/${venv}/bin
    PROG=${venvbin}/devpi-server
    opts="--restrict-modify root --host 0.0.0.0 --port $PORT"
    opts="--host 0.0.0.0 --port $PORT"
    supervisor_config="/code/supervisord.conf"
}

function use_venv() {
    if [ -d ${venvbin} ]; then
	. ${venvbin}/activate
    fi
}

function generate_password() {
    # We disable exit on error because we close the pipe
    # when we have enough characters, which results in a
    # non-zero exit status
    set +e
    tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 | tr -cd '[:alnum:]'
    set -e
}

function kill_devpi() {
    _PID=$(pgrep devpi-server)
    echo "ENTRYPOINT: Sending SIGTERM to PID $_PID"
    kill -SIGTERM "$_PID"
}

if [ "${1:-}" == "bash" ]; then
    exec "$@"
fi

defaults

use_venv

echo "Server root: $DEVPI_SERVER_ROOT"

DEVPI_ROOT_PASSWORD="${DEVPI_ROOT_PASSWORD:-}"
if [ -f "$DEVPI_SERVER_ROOT/.root_password" ]; then
    DEVPI_ROOT_PASSWORD=$(cat "$DEVPI_SERVER_ROOT/.root_password")
elif [ -z "$DEVPI_ROOT_PASSWORD" ]; then
    DEVPI_ROOT_PASSWORD=$(generate_password)
fi

if [ ! -d "$DEVPI_SERVER_ROOT" ]; then
    echo "ENTRYPOINT: Creating devpi-server root"
    mkdir -p "$DEVPI_SERVER_ROOT"
fi

initialize=no
if [ ! -f "$DEVPI_SERVER_ROOT/.serverversion" ]; then
    initialize=yes
    echo "ENTRYPOINT: Initializing server root $DEVPI_SERVER_ROOT"
    ${venvbin}/devpi-init --serverdir "$DEVPI_SERVER_ROOT"
    #${venvbin}/devpi-gen-config $opts
fi
if [ "$initialize" == "yes" ]; then
    echo "Initialization required"
fi

# start supervisor in foreground
${venvbin}/supervisord -n -c ${supervisor_config}
