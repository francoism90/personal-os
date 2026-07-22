# System Administration
alias sc='sudo systemctl'
alias scu='systemctl --user'
alias scl='sudo journalctl -u.service -f'
alias jf='journalctl -xf -n 1000'
alias cjf='sudo -i journalctl --vacuum-size=1B'

# rpm-ostree / Fedora Atomic
alias rpmst='rpm-ostree status'
alias rpmup='rpm-ostree upgrade'
alias rpmrb='rpm-ostree rollback'
alias rpmclean='sudo rpm-ostree cleanup -p'

# BlueBuild
alias bb='blujust'
alias bup='blujust update'

# Flatpak
alias fpl='flatpak list'
alias fpu='flatpak update'

# Toolbox / Distrobox
alias tbe='toolbox enter'
alias dbe='distrobox enter'

# Listing
alias la='ls -A'
alias lla='ll -A'
alias llh='ll -h'
alias llha='ll -hA'

# Tmux Management
alias ta='tmux attach-session -t'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'
alias ts='tmux switch-client -t'

# Git Workflow
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gcl='git clone'
alias gco='git checkout'
alias gp='git push'
alias gl='git pull'
alias gf='git fetch'
