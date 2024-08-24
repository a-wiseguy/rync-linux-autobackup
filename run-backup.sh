#!/bin/bash

TARGET_DESTINATION=""
BACKUP_SOURCE="${HOME}"  # Defaults to the home directory of the current user
IGNORE_LIST="./backup-ignorelist.txt"
BACKUP_ARCHIVE_NAME="home_backup.tar.gz"
BACKUP_ARCHIVE_PATH="/tmp/${BACKUP_ARCHIVE_NAME}"
MOUNT_POINT="/mnt/backup_nfs"  # Temporary mount point for NFS
KEEP_EXISTING_ARCHIVE=false

usage() {
    echo "Usage: $0 -m [nfs|ssh] -d <target_destination> [-s <backup_source>] [-k]"
    echo "  -m: Backup mode, either 'nfs' or 'ssh'"
    echo "  -d: Target destination. Full path for NFS or SSH (e.g., 'host:/path' or 'user@host:/path')"
    echo "  -s: (Optional) Source directory to backup. Defaults to the user's home directory."
    echo "  -k: (Optional) Keep existing archive. Skip creating a new tar.gz archive."
    exit 1
}

# Parse CLI arguments
while getopts "m:d:s:k" opt; do
    case "${opt}" in
        m)
            MODE=${OPTARG}
            ;;
        d)
            TARGET_DESTINATION=${OPTARG}
            ;;
        s)
            BACKUP_SOURCE=${OPTARG}
            ;;
        k)
            KEEP_EXISTING_ARCHIVE=true
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "${MODE}" ] || [ -z "${TARGET_DESTINATION}" ]; then
    echo "Error: Mode and target destination are required."
    usage
fi

if [ "${MODE}" != "nfs" ] && [ "${MODE}" != "ssh" ]; then
    echo "Error: Invalid mode selected. Please choose 'nfs' or 'ssh'."
    usage
fi

if [ "${MODE}" = "nfs" ]; then
    # Check if the target destination is a valid NFS format (e.g., "host:/path")
    if ! echo "${TARGET_DESTINATION}" | grep -q '^[^:]\+:/.*$'; then
        echo "Error: Invalid NFS target destination format. Expected format 'host:/path'."
        exit 1
    fi
elif [ "${MODE}" = "ssh" ]; then
    # Check if the target destination is a valid SSH format (e.g., "user@host:/path")
    if ! echo "${TARGET_DESTINATION}" | grep -q '^[^@]\+@[^:]\+:/.*$'; then
        echo "Error: Invalid SSH target destination format. Expected format 'user@host:/path'."
        exit 1
    fi
fi

# Create the backup archive (if not transfer existing at path)
if [ "${KEEP_EXISTING_ARCHIVE}" = false ]; then
    echo "Creating backup archive from ${BACKUP_SOURCE}..."
    tar --exclude-from=${IGNORE_LIST} -czf ${BACKUP_ARCHIVE_PATH} ${BACKUP_SOURCE}
    tar --exclude-from=${IGNORE_LIST} -czf ${BACKUP_ARCHIVE_PATH} ${BACKUP_SOURCE}
    echo "Backup archive created at ${BACKUP_ARCHIVE_PATH}"
    echo "Backup archive created at ${BACKUP_ARCHIVE_PATH}"
else
    echo "Skipping archive creation. Using existing archive at ${BACKUP_ARCHIVE_PATH}."
    echo "Skipping archive creation. Using existing archive at ${BACKUP_ARCHIVE_PATH}."
    if [ ! -f "${BACKUP_ARCHIVE_PATH}" ]; then
    if [ ! -f "${BACKUP_ARCHIVE_PATH}" ]; then
        echo "Error: No existing archive found at ${BACKUP_ARCHIVE_PATH}."
        echo "Error: No existing archive found at ${BACKUP_ARCHIVE_PATH}."
        exit 1
    fi
fi

# NFS mode
if [ "${MODE}" = "nfs" ]; then
    echo "Using NFS mode..."
    
    # Create temporary mount point if it doesn't exist
    if [ ! -d "${MOUNT_POINT}" ]; then
        sudo mkdir -p ${MOUNT_POINT}
    fi

    # Mount the NFS share
    echo "Mounting NFS share..."
    if ! sudo mount -t nfs ${TARGET_DESTINATION} ${MOUNT_POINT}; then
        echo "Error: Failed to mount NFS share."
        exit 1
    fi

    # Rsync the backup archive to the NFS share
    echo "Transferring backup archive via NFS..."
    if ! rsync -az --progress ${BACKUP_ARCHIVE_PATH} ${MOUNT_POINT}/${BACKUP_ARCHIVE_NAME}; then
    if ! rsync -az --progress ${BACKUP_ARCHIVE_PATH} ${MOUNT_POINT}/${BACKUP_ARCHIVE_NAME}; then
        echo "Error: Failed to transfer backup via NFS."
        sudo umount ${MOUNT_POINT}
        exit 1
    fi

    # Unmount the NFS share
    echo "Unmounting NFS share..."
    sudo umount ${MOUNT_POINT}

    # Clean up temporary mount point
    if [ -d "${MOUNT_POINT}" ]; then
        sudo rmdir ${MOUNT_POINT}
    fi

# simple rsync over SSH
elif [ "${MODE}" = "ssh" ]; then
    echo "Using SSH mode..."
    
    # Rsync the backup archive to the SSH destination
    echo "Transferring backup archive via SSH..."
    if ! rsync -az --progress ${BACKUP_ARCHIVE_PATH} ${TARGET_DESTINATION}; then
    if ! rsync -az --progress ${BACKUP_ARCHIVE_PATH} ${TARGET_DESTINATION}; then
        echo "Error: Failed to transfer backup via SSH."
        exit 1
    fi
fi

echo "Backup transfer completed successfully."
