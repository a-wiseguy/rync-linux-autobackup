# Linux Home folder backups to a NAS

Tiny personal convinence script to backup linux home folders to my NAS. Made configurable for creating and transferring home folder backups on a Linux system. It supports both NFS and SSH modes for transferring the backup archive to a specified target destination.

# Features
- full home folder backup while avoiding common useless directories and caches
- auto create and mount a temp NFS share

For now only supports: 
- NAS using NFS type targets
- normal rsync SSH transfer

Todo:
- WebDAV
- Nextcloud auto backup integration?


# Usage

Basic Usage

```bash
./run-backup.sh -m [nfs|ssh] -d <target_destination> [-s <backup_source>] [-k]
```

Options
```
    -m: (Required) Specifies the backup mode, either nfs or ssh.
    -d: (Required) Specifies the target destination. This should be the full path for either NFS (host:/path) or SSH (user@host:/path).
    -s: (Optional) Specifies the source directory to back up. Defaults to the current user's home directory if not provided.
    -k: (Optional) If provided, the script will skip creating a new tar.gz archive and reuse an existing archive at the specified path.
```

## Example Commands
Create and Transfer Backup via NFS

```bash
./run-backup.sh -m nfs -d host:/backups/desktop/home_backup.tar.gz
```
Reuse Existing Archive and Transfer via NFS

```bash
./run-backup.sh -m nfs -d host:/backups/desktop/home_backup.tar.gz -k
```
Create and Transfer Backup via SSH

```bash
./run-backup.sh -m ssh -d user@host:/srv/disk/backups/desktop/home_backup.tar.gz
```
Skip backup creation and only transfer via SSH

```bash
./run-backup.sh -m ssh -d user@host:/srv/disk/backups/desktop/home_backup.tar.gz -k
```
# Requirements

The script assumes that the tar, rsync, and mount utilities are installed on your system.
For SSH transfers, you should have SSH keys set up for passwordless authentication, or be prepared to enter your password during the process.
Ensure that the NFS server is reachable and that you have appropriate permissions to mount the NFS share.


# License

This script is licensed under the MIT License. See the LICENSE file for more information.
Contributing

Contributions are welcome! Please open an issue or submit a pull request with your changes. 