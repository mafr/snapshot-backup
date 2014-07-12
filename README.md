snapshot-backup
===============

The snapshot-backup tool creates full snapshot backups of a given directory,
keeping a configurable number of backups. To save space, it uses hardlinks
to share files that remain unchanged between backups. Unlike with other
backup tools, restore works by copying the latest snapshot using "cp -a".

To make use of the linking feature, you need a filesystem that supports
hardlinks (ext2 and later work well) and has enough space available. I
recommend creating backups on an external disk that is only mounted when
running the bacup for safety reasons.

Under the hood, snapshot-backup uses rsync for the linking and for its
file inclusion/exclusion mechanism. This means it should be reasonably
robust, but use it at your own risk and verify carefully that it works
for you.


References
----------

  * The [blog article](http://blog.mafr.de/2008/06/26/rsync-backups/) that
    explains how it works in detail

