#!/bin/bash
# sudo ./run_seqread_j8.sh

# Initialize variables with default values
export FILENAME="nvme0n1"
export LOOPS="1"

# Use getopts to parse named options
while getopts "f:l:" opt; do
    case ${opt} in
        f )
            export FILENAME="${OPTARG}"
            ;;
        l )
            export LOOPS="${OPTARG}"
            ;;
        \? )
            echo "Usage: $0 [-f filename] [-l loops]"
            exit 1
            ;;
    esac
done

# The shift command removes the parsed options from the argument list
shift $((OPTIND -1))

# Define the target NVMe device
FIO_JOB_FILE="seqread_j8.fio"
SYSFS_PATH="/sys/block/${FILENAME}/queue/max_hw_sectors_kb"

# Check if the device exists in sysfs
if [ ! -f "${SYSFS_PATH}" ]; then
    echo "Error: Cannot find sysfs entry for ${FILENAME}"
    exit 1
fi

# Fetch the max_hw_sectors_kb value
# Example output: 128
MAX_HW_SECTORS_KB=$(cat "${SYSFS_PATH:-128}")

echo "Target Device: /dev/${FILENAME}"
echo "Detected Maximum HW Sectors: ${MAX_HW_SECTORS_KB} KB"

# Export the value as an environment variable so Fio can read it
export BS="${MAX_HW_SECTORS_KB}"

echo "Starting ${FIO_JOB_FILE} with bs=${BS}k and loops=${LOOPS}"

# CRITICAL: Use 'sudo -E' to preserve the exported environment variable
# If you only use 'sudo', the BS variable will be lost in the root environment!
sudo -E fio ${FIO_JOB_FILE}
