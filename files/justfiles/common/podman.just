podman_sdk_apps := "com.visualstudio.code com.vscodium.codium dev.zed.Zed dev.zed.Zed-Preview com.jetbrains.PhpStorm"

# Enable the Podman SDK extension for installed Flatpak editors (VS Code, VSCodium, Zed, PhpStorm)
enable-podman-sdk:
    #!/usr/bin/bash
    set -euo pipefail

    if ! flatpak info org.freedesktop.Sdk.Extension.podman > /dev/null 2>&1; then
        echo "org.freedesktop.Sdk.Extension.podman is not installed."
        echo "Install it with: flatpak install flatpaks org.freedesktop.Sdk.Extension.podman"
        exit 1
    fi

    systemctl --user enable --now podman.socket

    installed="$(flatpak list --app --columns=application)"
    found=0

    for app in {{ podman_sdk_apps }}; do
        if ! grep -qx "${app}" <<< "${installed}"; then
            continue
        fi

        found=1
        echo "Enabling Podman SDK for ${app}"
        flatpak override --user --env=FLATPAK_ENABLE_SDK_EXT=podman "${app}"
        flatpak override --user --filesystem=xdg-run/podman:ro "${app}"

        # Zed has no direct Podman support, so route it through podman-remote
        case "${app}" in
            dev.zed.Zed | dev.zed.Zed-Preview)
                flatpak override --user --env=PODMAN_FLATPAK_FORCE_REMOTE=1 "${app}"
                ;;
        esac
    done

    if [ "${found}" = "0" ]; then
        echo "None of the supported editors are installed: {{ podman_sdk_apps }}"
        exit 1
    fi

    echo "Podman SDK enabled. Restart the editors, then finish the per-editor settings:"
    echo "https://github.com/francoism90/flatpaks/blob/main/src/org.freedesktop.Sdk.Extension.podman/README.md"

# Remove the Podman SDK overrides from installed Flatpak editors
remove-podman-sdk:
    #!/usr/bin/bash
    set -euo pipefail

    overrides="${XDG_DATA_HOME:-${HOME}/.local/share}/flatpak/overrides"

    for app in {{ podman_sdk_apps }}; do
        file="${overrides}/${app}"
        if [ ! -f "${file}" ]; then
            continue
        fi

        echo "Removing Podman SDK overrides for ${app}"
        sed -i \
            -e '/^FLATPAK_ENABLE_SDK_EXT=podman$/d' \
            -e '/^PODMAN_FLATPAK_FORCE_REMOTE=1$/d' \
            -e 's#xdg-run/podman:ro;##g' \
            -e '/^filesystems=$/d' \
            "${file}"
    done

    echo "Podman SDK overrides removed. The podman.socket user service was left enabled."
