#! /bin/sh
#
# A simple script for snapshot backups.
#
# Copyright (c) 2008, Matthias Friedrich <matt@mafr.de>
# Copyright (c) 2008, Michael Koehnlein <michael.koehnlein@googlemail.com>
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

# Default parameters. Override them via command line parameters.
# KEEP_NUM is the number of backups (that is, snapshot directories) to keep.
#
SOURCE_DIR=$HOME
DEST_DIR=/media/disk/backups/$(hostname)
KEEP_NUM=6

TMP_DIRNAME=backup.tmp

# Print an error message and exit.
die() {
	echo "$(basename $0): $1" 2>&1
	exit 1
}

# Print usage and exit.
usage_die() {
	echo "Usage: $(basename $0):" \
		 "[-s source_dir] [-d dest_dir] [-k keep_num]" 2>&1
	exit 1
}

# Parse command line arguments.
#
while getopts s:d:k: OPT; do
	case "$OPT" in
		s)	SOURCE_DIR=$OPTARG ;;
		d)	DEST_DIR=$OPTARG ;;
		k)	KEEP_NUM=$OPTARG ;;
		\?)	usage_die ;;
	esac
done

# Non-option parameters left? That's an error!
shift $(expr $OPTIND - 1)
test $# -eq 0 || usage_die


# If the directory isn't there then the drive probably isn't mounted.
#
cd "$DEST_DIR" 2> /dev/null \
	|| die "cannot change to directory $DEST_DIR (does it exist?)"


# For safety reasons we create the backup in a temporary directory first and
# move it later. If a previous temporary backup directory exists, fail.
#
test -e "$TMP_DIRNAME" \
	&& die "temporary backup directory exists: $DEST_DIR/$TMP_DIRNAME"

# Create the backup, but don't use --link-dest on first run to avoid warnings.
#
if [ -e backup.0 ]; then
	LINK_DEST="--link-dest=../backup.0"
fi
rsync --archive $LINK_DEST \
	--filter="merge $HOME/.backup.rc" \
	"$SOURCE_DIR/" "$TMP_DIRNAME/" || die "cannot create backup $SOURCE_DIR"


# Renumber all existing backups. backup.N is renamed to backup.N+1.
#
for i in $(seq $KEEP_NUM -1 1); do
	CURRENT=backup.$((i - 1))
	NEXT=backup.$i
	if [ -e $CURRENT ]; then
		mv $CURRENT $NEXT || die "cannot move backup $CURRENT"
	fi
done


# Now that everything went well, rename the temporary backup directory to its
# final destination.
#
mv "$TMP_DIRNAME" backup.0 || die "cannot rename $TMP_DIRNAME"


# Delete the oldest backup. We have to adjust permissions first,
# just in case there are directories we may not traverse or delete.
# We don't adjust permissions of files because they are shared across backups!
#
OLDEST=backup.$KEEP_NUM
if [ -e $OLDEST ]; then
	find $OLDEST -type d -print0 | xargs -0 chmod u+rwx && rm -rf $OLDEST \
		|| die "cannot delete the oldest backup $OLDEST"
fi

# EOF
