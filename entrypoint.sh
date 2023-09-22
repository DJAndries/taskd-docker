#!/bin/sh

set -e

# /home/taskd/data is supposedly stateful storage as in the same
# location the main data for taskd is stored.
if [ ! -f /home/taskd/data/.taskd-init ]; then
    echo "[!] Init file not found, running taskd-init."
    if [ -z "$TASKD_HOSTNAME" ] || [ -z "$TASKD_CERT_ORG" ] || [ -z "$TASKD_CERT_COUNTRY" ] || [ -z "$TASKD_CERT_STATE" ] || [ -z "$TASKD_CERT_LOCALITY" ]; then
	echo "[-] Error: not all necessary ENV variables provided for taskd-init, aborting."
	exit 1
    else
	echo "[+] Running taskd-init."
	/usr/local/bin/taskd-init
	touch /home/taskd/data/.taskd-init
	echo "[+] Initialization completed, starting taskd."
    fi
fi

exec /usr/local/bin/taskd server
