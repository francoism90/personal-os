# /etc/fish/conf.d/alias.fish
# Global alias configuration for Fish shell

# Guard: Only execute if the current shell session is interactive.
if status is-interactive

    # VS Code (Flatpak)
    alias vsc='flatpak run com.visualstudio.code'
    alias code='flatpak run com.visualstudio.code'

end
