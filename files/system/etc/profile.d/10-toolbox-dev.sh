# /etc/profile.d/10-toolbox-dev.sh
# Run the development tooling inside the dev toolbox (see `ujust setup-dev-toolbox`)
# instead of on the host. $HOME is shared with the toolbox, so config such as
# ~/.claude and ~/.config/gh is picked up on both sides.
# Mirrors /etc/fish/conf.d/toolbox-dev.fish.

# Inside a toolbox the real binaries are already on PATH; aliasing them there would recurse.
if [ ! -f /run/.toolboxenv ]; then
    for cmd in claude gh php composer node npm npx; do
        # shellcheck disable=SC2139
        alias "${cmd}=toolbox run --container dev ${cmd}"
    done
    unset cmd
fi
