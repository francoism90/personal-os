# Setup Claude Code
install-claude-code:
    #!/usr/bin/bash
    set -euo pipefail

    curl -fsSL https://claude.ai/install.sh | bash

# Remove Claude Code
remove-claude-code:
    #!/usr/bin/bash
    set -euo pipefail

    rm -f ~/.local/bin/claude
    rm -rf ~/.local/share/claude
