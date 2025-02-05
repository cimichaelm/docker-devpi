#!/bin/bash

function defaults() {
    PORT=3141
    u=devpi
    venv=env
    PREFIX=/
    venvbin=${PREFIX}/${venv}/bin
    PROG=${venvbin}/devpi-server
    opts="--restrict-modify root --host 0.0.0.0 --port $PORT"
    opts="--host 0.0.0.0 --port $PORT"
    supervisorconfig="/code/supervisord.conf"
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

defaults

use_venv

DEVPI_ROOT_PASSWORD="${DEVPI_ROOT_PASSWORD:-}"
if [ -f "$DEVPI_SERVER_ROOT/.root_password" ]; then
    DEVPI_ROOT_PASSWORD=$(cat "$DEVPI_SERVER_ROOT/.root_password")
elif [ -z "$DEVPI_ROOT_PASSWORD" ]; then
    DEVPI_ROOT_PASSWORD=$(generate_password)
fi

echo "Initializing devpi-server"
devpi use http://localhost:3141
devpi login root --password=''
echo "Setting root password to $DEVPI_ROOT_PASSWORD"
devpi user -m root "password=$DEVPI_ROOT_PASSWORD"
echo -n "$DEVPI_ROOT_PASSWORD" > "$DEVPI_SERVER_ROOT/.root_password"
devpi logoff

