setup-claude-code:
    #!/usr/bin/bash
    set -euo pipefail

    container="claude-agent"

    if ! toolbox list -c | grep -q "\b${container}\b"; then
        toolbox --assumeyes create "${container}"
    fi

    toolbox run --container "${container}" sudo dnf install -y nodejs
    toolbox run --container "${container}" bash -c 'curl -fsSL https://claude.ai/install.sh | bash'

    echo "Claude Code installed in the '${container}' toolbox. Enter it with: toolbox enter ${container}"

remove-claude-code:
    #!/usr/bin/bash
    set -euo pipefail

    toolbox rm --force claude-agent
