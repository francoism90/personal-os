# /etc/fish/conf.d/abbreviations.fish
# Global abbreviation configuration for Fish shell

# Guard: Only execute if the current shell session is interactive.
# Prevents errors in automated non-interactive tasks (scp, rsync, git plumbing).
if status is-interactive

    # System Administration
    abbr -a sc 'sudo systemctl'
    abbr -a scu 'systemctl --user'
    abbr -a scl 'sudo journalctl -f -u' # Fixed spacing for trailing service name
    abbr -a jf 'journalctl -xf -n 1000'
    abbr -a cjf 'sudo -i journalctl --vacuum-size=1B'

    # rpm-ostree / Fedora Atomic
    abbr -a rpmst 'rpm-ostree status'
    abbr -a rpmup 'rpm-ostree upgrade'
    abbr -a rpmrb 'rpm-ostree rollback'
    abbr -a rpmclean 'sudo rpm-ostree cleanup -p'

    # BlueBuild
    abbr -a bb 'bluebuild'
    abbr -a bu 'blujust'

    # Flatpak
    abbr -a fpl 'flatpak list'
    abbr -a fpu 'flatpak update'

    # Toolbox / Distrobox
    abbr -a tbe 'toolbox enter'
    abbr -a dbe 'distrobox enter'

    # Listing Dependencies
    # Fedora Fish defaults include 'll', but explicit definition ensures
    # safety inside minimal Distrobox/Toolbox containers.
    if not functions -q ll
        alias ll='ls -l'
    end

    # Listing
    abbr -a la 'ls -A'
    abbr -a lla 'll -A'
    abbr -a llh 'll -h'
    abbr -a llha 'll -hA'

    # Tmux Management
    abbr -a ta 'tmux attach-session -t'
    abbr -a tl 'tmux list-sessions'
    abbr -a tn 'tmux new-session -s'
    abbr -a ts 'tmux switch-client -t'

    # Git Workflow
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a gcl 'git clone'
    abbr -a gco 'git checkout'
    abbr -a gp 'git push'
    abbr -a gl 'git pull'
    abbr -a gf 'git fetch'

end
