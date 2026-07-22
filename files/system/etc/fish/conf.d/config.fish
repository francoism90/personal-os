fish_add_path -g ~/.local/bin

if status is-interactive

    if not test -f ~/.config/starship.toml
        mkdir -p ~/.config
        starship preset nerd-font-symbols -o ~/.config/starship.toml
    end

    if test -f ~/.config/fish/alias.fish
        source ~/.config/fish/alias.fish
    end

    if type -q starship
        starship init fish | source
    end

end
