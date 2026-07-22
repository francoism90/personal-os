#!/usr/bin/env bash
set -oue pipefail

# The user instance of systemd-tmpfiles-setup.service isn't enabled by
# default; --global enables it for every user via /etc/systemd/user, so
# /usr/share/user-tmpfiles.d/*.conf gets applied on next login without
# per-user action.
systemctl --global enable systemd-tmpfiles-setup.service
