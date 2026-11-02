#!/bin/bash
set -e

TARGET_DEV="/dev/nvme0n1"
MOUNT_DIR="/mnt/illumina/SSDtest"

# Safety check: Abort immediately if TARGET_DEV is the host OS root/boot drive!
if lsblk -no MOUNTPOINT "${TARGET_DEV}" | grep -qE "^(/|/boot|/boot/efi)$"; then
    echo "[ERROR] ${TARGET_DEV} contains the host OS filesystem! Aborting to prevent data loss."
    exit 1
fi

# Unmount the device and any existing partitions (e.g., nvme0n1p1) if mounted
sudo umount ${TARGET_DEV}* 2>/dev/null || true

# Format as ext4 with full-drive discard (Trim) and immediate metadata init
sudo mkfs.ext4 -F -E discard,lazy_itable_init=0,lazy_journal_init=0 "${TARGET_DEV}"

# Mount to the dedicated test folder on the test machine
sudo mkdir -p "${MOUNT_DIR}"
sudo mount "${TARGET_DEV}" "${MOUNT_DIR}"

echo "[OK] ${TARGET_DEV} formatted and mounted at ${MOUNT_DIR}"
df -h "${MOUNT_DIR}"
