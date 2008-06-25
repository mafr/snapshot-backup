#! /bin/sh
#
# A simple script for snapshot backups.
#

SOURCE_DIR=/home/matthias
DEST_DIR=/media/disk/backup

if [ ! -e "$DEST_DIR" ]; then
	echo "$0: directory $DEST_DIR doesn't exist" 2>&1
	exit 1
fi

cd "$DEST_DIR"

test -e backup.3 && rm -rf backup.3
test -e backup.2 && mv backup.2 backup.3
test -e backup.1 && mv backup.1 backup.2
test -e backup.0 && mv backup.0 backup.1

rsync -a --delete --link-dest=../backup.1 "$SOURCE_DIR/"  backup.0/

# EOF
