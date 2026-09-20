# /etc/fish/conf.d/toolbox-dev.fish
# Run the development tooling inside the dev toolbox (see `ujust setup-dev-toolbox`)
# instead of on the host. $HOME is shared with the toolbox, so config such as
# ~/.claude and ~/.config/gh is picked up on both sides.

# Inside a toolbox the real binaries are already on PATH; wrapping them there would recurse.
if not test -f /run/.toolboxenv
    for cmd in claude gh php composer node npm npx
        function $cmd --inherit-variable cmd
            toolbox run --container dev $cmd $argv
        end
    end
end
