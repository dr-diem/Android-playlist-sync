# Android-playlist-sync

The purpose of this script is to synchronise the set of audio files listed in a supplied set of playlist files, from the  device running the script to an Android phone mounted via SSH. For speed, the SSH server can be mapped to a wired ADB connection.  Any format of playlist that lists one file per line and lists each file path with an absolute path will work.

So far, I have implemented syncing from just one playlist rather than a folder full of them.

USAGE

The script takes two parameters:

1. The absolute path to the root folder of the source music library
2. The name of a playlist file.


It will use rsync to connect to localhost on port 2222. It is the user's responsibility to:

1. Have mapped localhost:2222 to an SSH server. To sync a playlist to a phone, the best solution is to use the following adb command to map that port to the same port on the phone:

```adb forward tcp:2222 tcp:2222```

N.B. 2222 is the default listening port for SSHelper - an Android app that implements SSHD and the one I happen to use.
 
2. Get SSHD running on the phone. This script assumes that the root folder when logged in will contain a sub-directory path named SDCard/Music (again, this is the default for SSHelper)
