# Allow containers to access host hardware devices
allow-container-device-access:
    #!/usr/bin/bash
    set -euo pipefail

    sudo setsebool -P container_use_devices on
    sudo setsebool -P container_use_dri_devices on

    sudo usermod -aG render,video "${USER}"

# Reset container access to host hardware devices
reset-container-device-access:
    #!/usr/bin/bash
    set -euo pipefail

    sudo setsebool -P container_use_devices off
    sudo setsebool -P container_use_dri_devices off
