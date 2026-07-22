enable-mac-randomization:
    #!/usr/bin/bash
    set -euo pipefail

    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo tee /etc/NetworkManager/conf.d/10-mac-randomization.conf > /dev/null <<'EOF'
    [connection-mac-randomization]
    ethernet.cloned-mac-address=stable
    wifi.cloned-mac-address=stable
    EOF
    sudo systemctl reload NetworkManager
    echo "MAC address randomization enabled. Please reconnect to your network for changes to take effect."

disable-mac-randomization:
    #!/usr/bin/bash
    set -euo pipefail

    sudo rm -f /etc/NetworkManager/conf.d/10-mac-randomization.conf
    sudo systemctl reload NetworkManager
    echo "MAC address randomization disabled. Please reconnect to your network for changes to take effect."
