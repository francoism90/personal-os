# Disable fish greeter
disable-fish-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    mkdir -p "${HOME}/.config/fish/conf.d"
    tee "${HOME}/.config/fish/conf.d/00-greeter.fish" > /dev/null <<'EOF'
    #!/usr/bin/fish
    set -g fish_greeting
    EOF

    echo "Fish greeter disabled. Please restart your terminal for changes to take effect."

# Restore fish greeter
restore-fish-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    rm -f "${HOME}/.config/fish/conf.d/00-greeter.fish"
    echo "Fish greeter enabled. Please restart your terminal for changes to take effect."

# Enable fastfetch greeter
enable-fastfetch-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    mkdir -p "${HOME}/.config/fish/conf.d"
    tee "${HOME}/.config/fish/conf.d/01-fastfetch-greeter.fish" > /dev/null <<'EOF'
    #!/usr/bin/fish
    if status is-interactive
        fastfetch
    end
    EOF

    echo "Fastfetch greeter enabled. Please restart your terminal for changes to take effect."

# Remove fastfetch greeter
remove-fastfetch-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    rm -f "${HOME}/.config/fish/conf.d/01-fastfetch-greeter.fish"
    echo "Fastfetch greeter disabled. Please restart your terminal for changes to take effect."
