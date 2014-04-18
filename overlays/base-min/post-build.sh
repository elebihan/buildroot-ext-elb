#!/bin/sh

mkdir_if_missing() {
	test -d $1 || mkdir -p $1
}

echo "Adding missing directories"
mkdir_if_missing ${TARGET_DIR}/etc/udev/rules.d

# Empty rule to avoid Ethernet interface renaming.
touch ${TARGET_DIR}/etc/udev/rules.d/80-net-name-slot.rules
