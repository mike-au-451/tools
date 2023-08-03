#!/bin/bash

PIHOLE=pihole.local
IP=$(avahi-resolve -4 -n $PIHOLE 2> /dev/null | cut -f2)
if [[ -z "$IP" ]]
then
	echo "ERROR: failed to resolve $PIHOLE"
	exit
fi

CREDENTIALS="$HOME/.config/smb/smb.credentials"
if [[ ! -f "$CREDENTIALS" ]]
then
	echo "FATAL: failed to find smb credentials"
	exit
fi

sudo mount -t cifs -o rw,credentials="$CREDENTIALS" //$IP/share /mnt/share

