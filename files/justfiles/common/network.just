# Disable MAC address randomization for NetworkManager
disable-mac-randomization:
    #!/usr/bin/bash
    set -euo pipefail

    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo tee /etc/NetworkManager/conf.d/10-mac-randomization.conf > /dev/null <<'EOF'
    [connection-mac-randomization]
    ethernet.cloned-mac-address=permanent
    wifi.cloned-mac-address=permanent
    EOF
    sudo systemctl reload NetworkManager
    echo "MAC address randomization disabled. Please reconnect to your network for changes to take effect."

# Reset MAC address randomization settings for NetworkManager
reset-mac-randomization:
    #!/usr/bin/bash
    set -euo pipefail

    sudo rm -f /etc/NetworkManager/conf.d/10-mac-randomization.conf
    sudo systemctl reload NetworkManager
    echo "MAC address randomization enabled. Please reconnect to your network for changes to take effect."

# Set up Tailscale: allow the current user to manage it (e.g. via KTailctl) and log in
setup-tailscale:
    #!/usr/bin/bash
    set -euo pipefail

    sudo systemctl enable --now tailscaled.service
    sudo tailscale set --operator="${USER}"
    tailscale up
    echo "Tailscale is set up. ${USER} can now manage it without sudo (e.g. via KTailctl)."

# Log out of Tailscale, remove the current user as operator and disable tailscaled
reset-tailscale:
    #!/usr/bin/bash
    set -euo pipefail

    sudo tailscale logout || true
    sudo tailscale set --operator= || true
    sudo systemctl disable --now tailscaled.service
    echo "Logged out of Tailscale and disabled tailscaled.service."
