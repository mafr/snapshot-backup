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
#
SOURCE_DIR=$HOME
DEST_DIR=/media/disk/backup

# If the directory isn't there then the drive probably isn't mounted.
if [ ! -e "$DEST_DIR" ]; then
	echo "$0: directory $DEST_DIR doesn't exist" 2>&1
	exit 1
fi

cd "$DEST_DIR"

test -e backup.3 && rm -rf backup.3
test -e backup.2 && mv backup.2 backup.3
test -e backup.1 && mv backup.1 backup.2
test -e backup.0 && mv backup.0 backup.1

rsync --archive --link-dest=../backup.1 \
	--filter="merge $HOME/.backup.rc" \
	"$SOURCE_DIR/" backup.0/

# EOF
