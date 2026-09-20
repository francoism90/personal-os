# Set up the dev toolbox container (Claude Code, gh, Node, PHP, Composer, search/JSON/lint tools)
setup-dev-toolbox:
    #!/usr/bin/bash
    set -euo pipefail

    container="dev"

    # Match the exact container name column, "dev" is too short for a loose grep
    if ! toolbox list -c | awk -v name="${container}" 'NR > 1 && $2 == name { found = 1 } END { exit !found }'; then
        toolbox --assumeyes create "${container}"
    fi

    toolbox run --container "${container}" sudo dnf upgrade --refresh -y
    toolbox run --container "${container}" sudo dnf install -y \
        ripgrep fd-find jq yq fzf bat git-delta just ShellCheck \
        php-cli composer \
        php-bcmath php-gd php-intl php-mbstring php-mysqlnd php-pdo php-pecl-zip php-pgsql php-process php-sodium php-xml \
        nodejs gh
    toolbox run --container "${container}" bash -c 'curl -fsSL https://claude.ai/install.sh | bash'

    echo "Dev tools installed in the '${container}' toolbox. Enter it with: toolbox enter ${container}"

# Remove the dev toolbox container
remove-dev-toolbox:
    #!/usr/bin/bash
    set -euo pipefail

    toolbox rm --force dev
