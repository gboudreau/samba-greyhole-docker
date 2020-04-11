# Samba + Greyhole in Docker

See `helpers/samba-greyhole.service` to learn how to run this Docker container.  
This file can also be used to run this Docker container using `systemd`.  
`helpers/monit-samba-greyhole.conf` can be used to monitor, and restart as needed, the systemd service. Just symlink it in the `/etc/monit/conf.d/` or equivalent folder.

You will need `/etc/samba` and `/var/lib/samba` folders from a previously working Samba install, as well as an already configured `greyhole.conf`.

Make sure you mount (`-v [host_path]:[container_path]`) all the required folders referred to in your `smb.conf` (`path = ...` for all shares), and in your `greyhole.conf` (`storage_pool_drive = ...`)

You will need to edit your `greyhole.conf` to point to your host's IP address, instead of `localhost`, for `db_host`.  
(I am myself using the `mariadb/server:10.4` Docker image.)

If you'd like to be able to view/grep the Greyhole log files, make sure you put them in a folder that is mounted from your host.  
Ref: `greyhole_log_file` & `greyhole_error_log_file` in your `greyhole.conf`)

Symlink `helpers/greyhole.sh` as `/usr/local/bin/greyhole` on your host, to be able to execute any `greyhole ...` command on you host (`greyhole --fsck...`, `greyhole --stats`, `greyhole --logs`, etc.)

`helpers/restart-greyhole.sh` and `helpers/restart-samba.sh` can be used to restart the Greyhole and Samba daemons, within a running container, without having to restart the container itself.

## Installation

Here's the script I am using to install & run this Docker container on a Debian Stretch host.

```shell script
TARGET_PATH="/home/gb/samba-greyhole"
systemctl stop smbd nmbd
systemctl disable smbd nmbd
git clone https://github.com/gboudreau/samba-greyhole-docker.git "$TARGET_PATH"
# Change WorkingDirectory in helpers/samba-greyhole.service; also change the folders & files mounted using -v
mkdir -p /usr/share/greyhole/
ln -s "$TARGET_PATH/helpers/greyhole.sh" /usr/local/bin/greyhole
ln -s "$TARGET_PATH/helpers/samba-greyhole.service" /etc/systemd/system/samba-greyhole.service
systemctl enable samba-greyhole
```

Add Greyhole's cron jobs in your favorite crontab file (`/etc/cron.d/greyhole`, `crontab -e`, etc.):
```crontab
#                Daily (conditional) fsck
0 3 * * Mon-Sat  /usr/local/bin/greyhole --fsck --if-conf-changed --email-report --dont-walk-metadata-store > /dev/null
#                Weekly (forced) fsck
0 3 * * Sun      rm -f /usr/share/greyhole/gh-disk-usage.log ; /usr/local/bin/greyhole --fsck --email-report --dont-walk-metadata-store --disk-usage-report > /dev/null
* * * * *        /usr/local/bin/greyhole --process-spool --keepalive > /dev/null
```
