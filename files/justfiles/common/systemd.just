enable-linger:
    #!/usr/bin/bash
    set -euo pipefail

    loginctl enable-linger "${USER}"

disable-linger:
    #!/usr/bin/bash
    set -euo pipefail

    loginctl disable-linger "${USER}"
