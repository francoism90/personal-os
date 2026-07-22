disable-fish-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    mkdir -p "${HOME}/.config/fish/conf.d"
    tee "${HOME}/.config/fish/conf.d/00-greeter.fish" > /dev/null <<'EOF'
    #!/usr/bin/fish
    set -g fish_greeting

    if status is-login
        echo "Welcome to your system, $USER!"
    end
    EOF

    echo "Fish greeter disabled. Please restart your terminal for changes to take effect."

enable-fish-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    rm -f "${HOME}/.config/fish/conf.d/00-greeter.fish"
    echo "Fish greeter enabled. Please restart your terminal for changes to take effect."

disable-fastfetch-greeter:
    #!/usr/bin/bash
    set -euo pipefail

    rm -f "${HOME}/.config/fish/conf.d/01-fastfetch-greeter.fish"
    echo "Fastfetch greeter disabled. Please restart your terminal for changes to take effect."

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
