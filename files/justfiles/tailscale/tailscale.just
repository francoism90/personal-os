# Tailscale helpers for images whose base doesn't set Tailscale up itself (COSMIC on the Fedora base).
# Aurora enables tailscaled by default and makes the first user the operator, so there it's just
# `tailscale up` (and `ujust toggle-tailscale` to turn it off).

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
