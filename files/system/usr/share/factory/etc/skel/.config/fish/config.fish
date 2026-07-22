# System & User Binaries
fish_add_path ~/.local/bin

if status is-interactive
    # Load Aliases
    source ~/.config/fish/alias.fish

    # Initialize Starship Prompt (Placed at the end)
    starship init fish | source
end
