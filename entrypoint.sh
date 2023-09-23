#!/bin/sh

set -e

# Default to 365 days of certificate validity if not set
TASKD_CERT_EXPIRATION_DAYS="${TASKD_CERT_EXPIRATION_DAYS:-365}"

# Copy the PKI folder to the homedir "writeable" folder
# This is used so that this path can be dynamicall mounted
# and the container can still run with a readOnly Filesystem

cp -r /use/local/share/doc/taskd/pki /home/taskd/writeable/

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
