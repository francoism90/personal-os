# Disable MAC address randomization for NetworkManager
disable-mac-randomization:
    #!/usr/bin/bash
    set -euo pipefail

    sudo mkdir -p /etc/NetworkManager/conf.d
    sudo tee /etc/NetworkManager/conf.d/10-mac-randomization.conf > /dev/null <<'EOF'
    [connection-mac-randomization]
    ethernet.cloned-mac-address=stable
    wifi.cloned-mac-address=stable
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

# Toggle the NetworkManager Wi-Fi backend between wpa_supplicant (default) and iwd
toggle-iwd:
    #!/usr/bin/bash
    set -euo pipefail

    conf=/etc/NetworkManager/conf.d/20-wifi-backend.conf
    if [ -f "$conf" ]; then
        sudo rm -f "$conf"
        sudo systemctl disable --now iwd.service
        sudo systemctl enable wpa_supplicant.service
        sudo systemctl restart NetworkManager
        echo "Wi-Fi backend switched to wpa_supplicant."
    else
        sudo mkdir -p /etc/NetworkManager/conf.d
        sudo tee "$conf" > /dev/null <<'CONF'
    [device]
    wifi.backend=iwd
    CONF
        sudo systemctl disable --now wpa_supplicant.service
        sudo systemctl enable --now iwd.service
        sudo systemctl restart NetworkManager
        echo "Wi-Fi backend switched to iwd. Saved NetworkManager connections are kept; reconnect if needed."
    fi

# Set up Tailscale: allow the current user to manage it (e.g. via KTailctl) and log in
setup-tailscale:
    #!/usr/bin/bash
    set -euo pipefail

    sudo systemctl enable --now tailscaled.service
    sudo tailscale set --operator="${USER}"
    tailscale up
    echo "Tailscale is set up. ${USER} can now manage it without sudo (e.g. via KTailctl)."

# Log out of Tailscale and remove the current user as operator
reset-tailscale:
    #!/usr/bin/bash
    set -euo pipefail

    sudo tailscale logout || true
    sudo tailscale set --operator=
    echo "Logged out of Tailscale. tailscaled.service was left enabled."
