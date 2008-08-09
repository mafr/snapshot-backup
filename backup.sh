#! /bin/sh
#
# A simple script for snapshot backups.
#
# Copyright (c) 2008, Matthias Friedrich <matt@mafr.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#

# Change these directories to whatever makes sense on your system!
# KEEP_NUM is the number of backups (that is, snapshot directories) to keep.
#
KEEP_NUM=4
SOURCE_DIR=$HOME
DEST_DIR=/media/disk/backup

# Print an error message and exit.
die() {
	echo "$0: $1" 2>&1
	exit 1
}

# If the directory isn't there then the drive probably isn't mounted.
cd "$DEST_DIR" 2> /dev/null || die "cannot change to directory $DEST_DIR"


# Renumber all existing backups. backup.N is renamed to backup.N+1.
#
for i in $(seq $KEEP_NUM -1 1); do
	CURRENT=backup.$((i - 1))
	NEXT=backup.$i
	if [ -e $CURRENT ]; then
		mv $CURRENT $NEXT || die "cannot move backup $CURRENT"
	fi
done


rsync --archive --link-dest=../backup.1 \
	--filter="merge $HOME/.backup.rc" \
	"$SOURCE_DIR/" backup.0/ || die "cannot create backup $SOURCE_DIR"


# Delete the oldest backup. We have to adjust permissions first,
# just in case there are directories we may not traverse or delete.
#
OLDEST=backup.$KEEP_NUM
if [ -e $OLDEST ]; then
	chmod -R u+rwx $OLDEST && rm -rf $OLDEST \
		|| die "cannot delete the oldest backup $OLDEST"
fi

# EOF
