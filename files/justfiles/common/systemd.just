# Enable linger for the current user
enable-linger:
    #!/usr/bin/bash
    set -euo pipefail

    loginctl enable-linger "${USER}"

# Disable linger for the current user
disable-linger:
    #!/usr/bin/bash
    set -euo pipefail

    loginctl disable-linger "${USER}"
