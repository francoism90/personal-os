# Apply SSD/NVMe performance flags to LUKS devices
apply-luks-nvme-flags:
    #!/usr/bin/bash
    set -euo pipefail
    shopt -s nullglob

    for mapper in /dev/mapper/luks-*; do
        name="${mapper##*/}"
        device="$(sudo cryptsetup status "${mapper}" | awk '/device:/ {print $2}')"
        rota="$(lsblk -ndo ROTA "${device}")"

        if [ "${rota}" = "0" ]; then
            echo "Applying SSD/NVMe performance flags to ${mapper}"
            sudo cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh "${name}"
        fi
    done

# Reset SSD/NVMe performance flags for LUKS devices
reset-luks-nvme-flags:
    #!/usr/bin/bash
    set -euo pipefail
    shopt -s nullglob

    for mapper in /dev/mapper/luks-*; do
        name="${mapper##*/}"
        echo "Removing SSD/NVMe performance flags from ${mapper}"
        sudo cryptsetup --persistent refresh "${name}"
    done
