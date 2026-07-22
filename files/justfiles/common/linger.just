setup-linger:
    #!/usr/bin/bash
    set -euo pipefail

    loginctl enable-linger "${USER}"

remove-linger:
    #!/usr/bin/bash
    set -euo pipefail

    loginctl disable-linger "${USER}"
