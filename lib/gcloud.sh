#!/bin/bash

# Credentials for the devops-environment (docker)

function gcloud-env {
	if [[ -n "$GOOGLE_APPLICATION_CREDENTIALS" ]]
	then
		rm -f "$GOOGLE_APPLICATION_CREDENTIALS"
		unset GOOGLE_APPLICATION_CREDENTIALS
	fi

	PROJECT=
	case "$1" in
	dev)
		PROJECT=citrus-dev-285703
		;;
	personal)
		PROJECT=iron-zodiac-298904
		;;
	prod)
		PROJECT=citrus
		;;
	*)
		;;
	esac
	if [[ -n "$PROJECT" ]]
	then
		gcloud auth application-default login
		export GOOGLE_APPLICATION_CREDENTIALS=/home/mike/.config/gcloud/application_default_credentials.json
	fi
}

# Start with clean credentials,
# run gcloud-env to set up new credentials.
# This seems pretty dangerous because a change in one shell will change
# credentials for *all* shells.
[[ -n "$GOOGLE_APPLICATION_CREDENTIALS" && -f "$GOOGLE_APPLICATION_CREDENTIALS" ]] && rm $GOOGLE_APPLICATION_CREDENTIALS
unset GOOGLE_APPLICATION_CREDENTIALS

alias gc=gcloud

# echo see https://console.cloud.google.com
