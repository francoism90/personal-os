# System Administration
alias sc='sudo systemctl'
alias scu='systemctl --user'
alias scl='sudo journalctl -u.service -f'
alias jf='journalctl -xf -n 1000'
alias cjf='sudo journalctl --vacuum-size=1B'

# rpm-ostree / Fedora Atomic
alias rpmst='rpm-ostree status'
alias rpmup='rpm-ostree upgrade'
alias rpmrb='rpm-ostree rollback'
alias rpmclean='sudo rpm-ostree cleanup -p'
alias rpmlog='rpm-ostree db diff -c'

# bootc (needs root)
alias bcst='sudo bootc status'
alias bcup='sudo bootc upgrade'
alias bcrb='sudo bootc rollback'
alias bcsw='sudo bootc switch'

# BlueBuild
alias bu='blujust'
alias bup='blujust update'
alias upd='blujust update'

# Flatpak
alias fpl='flatpak list'
alias fpu='flatpak update'

# Podman
alias pps='podman ps'
alias ppsa='podman ps -a'
alias pi='podman images'
alias plo='podman logs -f'
alias pex='podman exec -it'
alias prun='podman run'
alias pst='podman start'
alias psp='podman stop'
alias pre='podman restart'
alias prm='podman rm'
alias prmi='podman rmi'
alias ppull='podman pull'
alias pbuild='podman build'
alias pvol='podman volume ls'
alias pnet='podman network ls'
alias pprune='podman system prune -a'

# VS Code (Flatpak)
alias vsc='flatpak run com.visualstudio.code'
alias code='flatpak run com.visualstudio.code'

# Toolbox / Distrobox
alias tbe='toolbox enter'
alias tbr='toolbox run'
alias dbe='distrobox enter'

# Listing
alias la='ll -hA'
alias llh='ll -h'

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
