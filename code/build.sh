#!/bin/sh
# file: build.sh
# Author: Michael Moscovitch
#

defaults()
{

    tmpdir=/var/tmp
    prefix="/devpi"
    devpiuser=devpi
    storagedir=${STORAGE:-"/storage"}
    codedir="/code"
}

# change permission and ownership
fix_permissions()
{
    Lpath=$1

    if [ -d "${Lpath}" ]; then
        chmod 0755 "${Lpath}"
        chown -R ${devpiuser}":"${devpiuser} "${Lpath}"
    fi
}

# create a directory if it does not exist
create_directory()
{
    Lpath=$1

    if [ ! -d "${Lpath}" ]; then
        mkdir -p "${Lpath}"
    fi
}


# intialize directories
devpi_init_fs()
{

    if [ ! -f  $DEVPI_SERVER_ROOT/.serverversion ]; then
	create_directory $DEVPI_SERVER_ROOT
        fix_permissions $DEVPI_SERVER_ROOT
    fi
}


create_users()
{
    Lu=${devpiuser}
    adduser $Lu --home /home/users/$u --shell /bin/bash --disabled-password --gecos "$Lu"
}

check_status()
{
    date
    echo "user: ${devpiuser}"
    echo "default storagedir: ${storagedir}"
    grep $u /etc/passwd
    ls -lah ${storagedir}
    ls -lah ${codedir}    
}

defaults

create_users

create_directory ${storagedir}
fix_permissions  ${storagedir}

check_status
