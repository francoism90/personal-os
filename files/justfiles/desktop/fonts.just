# Install FiraCode Nerd Fonts
install-firacode-nerd-fonts:
    #!/usr/bin/bash
    set -euo pipefail

    font_dir="${HOME}/.local/share/fonts/FiraCode"

    mkdir -p "${font_dir}"
    curl -fLo /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip
    unzip -o /tmp/FiraCode.zip -d "${font_dir}"
    rm -f /tmp/FiraCode.zip
    fc-cache -fv
    echo "FiraCode Nerd Fonts installed. Please restart your terminal for changes to take effect."

# Remove FiraCode Nerd Fonts
remove-firacode-nerd-fonts:
    #!/usr/bin/bash
    set -euo pipefail

    rm -rf "${HOME}/.local/share/fonts/FiraCode"
    fc-cache -fv
    echo "FiraCode Nerd Fonts removed. Please restart your terminal for changes to take effect."
