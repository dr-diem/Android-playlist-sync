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
# along with this program. If not, see<https://www.gnu.org/licenses/>.

SPATH="/usr/local/sbin"
LOG=/var/log/sync_playlists_to_MTP.log

printf "\n\n\nStarting playlist sync on $(date)\n\n" >>${LOG} 2>&1

# validate parameters

takes three parameters - a filename, a local path and an MTP path
the file contains a list of .m3u playlists, the local path is the music library root, the MTP path is the Android phone music library root
error check command-line parameter
open file (error if not found)
iterate over lines in file
	read name of playlist file
	open playlist file
	iterate over lines in the file
		rsync file to destination
	end iteration
end iteration