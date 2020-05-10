#!/bin/bash

# Copyright (C) 2019 Ian Silvester <iansilvester@fastmail.fm>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see<https://www.gnu.org/licensse/>.

# Sync a playlist to an SSH server (e.g. an Android phone... including via ADB...)

# This program takes two parameters:
# - the absolute path to the root folder of the source music library
# - the name of a playlist file.
#
# It will use rsync to connect to localhost on port 2222; it is the user's responsibility to:
#
# 1. have mapped this port to an SSH server. To sync a playlist to a phone, the best solution
#	 is to use this adb command to map that port to the same port on the phone
#	 (which is the default listening port for SSHelper - an Android app that implements SSHD):
#
#      adb forward tcp:2222 tcp:2222
#
# 2. Get  SSHD running on the phone. This script assumes the root folder when logged in will 
#	 contain a sub-directory path named SDCard/Music (again, this is the default for SSHelper)

# Errors FAQ
#
# error: unknown host service - this means either that the phone is not connected via USB or
#								that USB debugging is not enable on the phone.
#

SPATH="/usr/local/sbin"
LOG=/var/log/sync_playlist.log

# exit proc, displaying a supplied string before doing so
die () {
    echo "$@"  |& tee -a ${LOG}
    exit 1
}

# test if ssh connection is working
#SSH_TEST=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -p 2222 localhost | grep "Connection refused")

printf "\n\n\nStarting playlist sync on $(date)\n\n"  |& tee -a ${LOG}

# validate that both parameters were provided
[ "$#" -eq 2 ] || die "2 arguments required, $# provided (absolute path to root of source music library, m3u file to sync)"

printf "\nBefore we begin, have you:\n\n1. Plugged your phone in to this computer via USB?\n2. Enabled USB debug in Developer Settings?\n3. Executed 'adb forward tcp:2222 tcp:2222' to map local port 2222 to the same port on the phone?\n4. Started an sshd server on the phone?\n\n"
read  -p "Type 'y' to continue or 'n' to abort: " reply
[ "$reply" == "y" ] || die "Quitting"

# process .m3u file to a temp file, keeping only lines that begin with a "/" (that is, file paths of music files)
TEMP_FILE=$(mktemp)
grep -i ^/ "$2" > $TEMP_FILE

# ensure the source library path has a terminating /
case $1 in
     */) # path ends with /, nothing to do
		 SOURCE_PATH="$1"
		 ;;
     *)	 # append a /
		 SOURCE_PATH="$1/"
		;;
esac

# now strip the source library path from the files in the playlist to make them relative
# (using # as the sed command field separator because the paths will contain /)
sed -i -e "s#^$SOURCE_PATH##" $TEMP_FILE

# pass temp file to rsync for copying from the source library to the destination library
# the destination assumes the directory setup supplied by the SSHelper Android app; the root
# contains just one subdir - SDCard - that is equivalent to /Storage/Emulated/0
# rsync parameters:
# -v - be verbose
# -t - preserve file modification timestamps
# -h - show numbers as human-readable
# -e - use this to pass a non-standard port to the ssh client
rsync -vth -e "ssh -p 2222" --progress --files-from=$TEMP_FILE "$SOURCE_PATH" localhost:SDCard/Music |& tee -a ${LOG}

# delete temp file
rm "${TEMP_FILE}"