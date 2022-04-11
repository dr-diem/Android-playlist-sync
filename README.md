# Android-playlist-sync

The purpose of these scripts is to synchronise the set of audio files listed in a supplied (set of) playlist files, from the  device running the script to an Android phone mounted via SSH. For speed, the SSH server can be mapped to a wired ADB connection.  Any format of playlist that lists one file per line and lists each file path with an absolute path will work.

So far, I have implemented syncing from just one playlist rather than a folder full of them.

/copy_playlist.sh/
This script simply copies all files listed in the playlist from the source library to the phone. Anything present on the phone will not be deleted. This means that, if the playlist is changed over time, anything removed from the playlist will remain on the phone. For this reason I also provide the following sync script.

/sync_playlist.sh/
This will genuinely sync - i.e. any file not present in the playlist but present on the phone will be deleted. Due to a limitation of rsync (the --files-from option does not delete from destination), this script is significantly slower since it needs to generate a temporary local directory with copies of all files in the playlist, then syncs that with the phone.

USAGE (same for both scripts)

The scripts takes two parameters:

1. The absolute path to the root folder of the source music library
2. The name of a playlist file.


It will use rsync to connect to localhost on port 2222. It is the user's responsibility to:

1. Have mapped localhost:2222 to an SSH server. To sync a playlist to a phone, the best solution is to use the following adb command to map that port to the same port on the phone:

```adb forward tcp:2222 tcp:2222```

N.B. 2222 is the default listening port for SSHelper - an Android app that implements SSHD and the one I happen to use.
 
2. Get SSHD running on the phone. This script assumes that the root folder when logged in will contain a sub-directory path named SDCard/Music (again, this is the default for SSHelper)

# What no MTP?

I don't know if you've noticed but don't all MTP implementations seem to suck badly? Perhaps I've just been unlucky, but I think it's just that the protocol is sucky itself. rsync/SSH/ADB is fast (~2.5GB/min or roughly 43MB/s), reliable, recoverable (rsync will pick up where it left off and only sync changes) and, if that weren't enough, well-supported!
