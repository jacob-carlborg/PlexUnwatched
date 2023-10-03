Finder sync extension that shows unwatched/partially watched items from Plex.

The intention is that the Plex items are either located on the computer running
the extension or are mounted using a remote file system (SMB/AFP).

Use the host application to configure the extension. The following options are
available:

* `Remote Path` - One of the folders from one of the Plex libraries as
    configured in Plex.

* `Local Path` - The corresponding path where the Plex folder is accessible on
    the computer running the Finder extension

* `Sync Type` - Indicates if the badge should be placed on the unwatched file or
    its containing directory

Currently only Movie and Video Plex libraries are supported.
