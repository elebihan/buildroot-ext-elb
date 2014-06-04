#!/bin/sh

set -e

mkdir_if_missing() {
	test -d $1 || mkdir -p $1
}

RANDOM_SEED=${TARGET_DIR}/var/lib/random-seed

echo "Pruning SysV leftovers"
rm -rf ${TARGET_DIR}/etc/init.d

echo "Updating /run, /var..."
rm -f ${TARGET_DIR}/var/tmp
rm -f ${TARGET_DIR}/var/run
rm -f ${TARGET_DIR}/var/lock
rm -rf ${TARGET_DIR}/run
mkdir -p ${TARGET_DIR}/run
ln -sf ../run ${TARGET_DIR}/var/run
ln -sf ../run ${TARGET_DIR}/var/lock

echo "Adding missing directories"
mkdir_if_missing ${TARGET_DIR}/etc/dropbear
mkdir_if_missing ${TARGET_DIR}/etc/systemd/system/sockets.target.wants
mkdir_if_missing ${TARGET_DIR}/etc/udev/rules.d

# Empty rule to enable classic unpredictable network interface names
ln -sf /dev/null ${TARGET_DIR}/etc/udev/rules.d/80-net-setup-link.rules

echo "Enabling custom Systemd services"

# Enable randomness generator
if grep -q -F "BR2_PACKAGE_HAVEGED=y" ${BR2_CONFIG}; then
	ln -sf ../haveged.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/haveged.service
else
	rm -f ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/.service
	sed -i -e '/Requires=haveged.service/d' ${TARGET_DIR}/etc/systemd/system/dropbearkey.service
fi

# Enable network manager
if grep -q -F "BR2_PACKAGE_SYSTEMD_NETWORKD=y" ${BR2_CONFIG}; then
	rm -f ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service
	ln -sf /lib/systemd/system/systemd-networkd.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/systemd-networkd.service
	ln -sf /run/systemd/network/resolv.conf ${TARGET_DIR}/etc/resolv.conf
else
	# Enable dhcpcd
	rm -f ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/systemd-networkd.service
	ln -sf ../dhcpcd@.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service
fi

# Enable SSH server
rm -f ${TARGET_DIR}/etc/systemd/system/dropbear.service
rm -f ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/dropbear.service
ln -sf ../dropbear@.socket ${TARGET_DIR}/etc/systemd/system/sockets.target.wants/dropbear@.socket
ln -sf ../dropbearkey.service ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/dropbearkey.service

# Enable remote journal access
if grep -q -F "BR2_PACKAGE_SYSTEMD_JOURNAL_GATEWAY=y" ${BR2_CONFIG}; then
	ln -sf /lib/systemd/system/systemd-journal-gatewayd.socket ${TARGET_DIR}/etc/systemd/system/sockets.target.wants/systemd-journal-gatewayd.socket
else
	rm -f ${TARGET_DIR}/etc/systemd/system/sockets.target.wants/systemd-journal-gatewayd.socket
fi

# Enable gettys
ln -sf ../../../../lib/systemd/system/getty@.service ${TARGET_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service

echo "Initializing ${RANDOM_SEED}"
touch ${RANDOM_SEED}
chmod 600 ${RANDOM_SEED}
dd if=/dev/urandom of=${RANDOM_SEED} count=1 bs=512 2>/dev/null
