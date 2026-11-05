# Workaround for Flatpak GTK apps ignoring Plasma's Breeze colours (e.g. dark mode):
# https://github.com/flathub/org.gtk.Gtk3theme.Breeze/issues/170#issuecomment-5571833585

gtk_theme_filesystems := "xdg-config/gtk-3.0:ro xdg-config/gtk-4.0:ro"

# Let all Flatpak GTK apps follow the Plasma Breeze colour scheme (incl. dark mode)
enable-flatpak-breeze-theme:
    #!/usr/bin/bash
    set -euo pipefail

    if ! flatpak info org.gtk.Gtk3theme.Breeze > /dev/null 2>&1; then
        echo "org.gtk.Gtk3theme.Breeze is not installed."
        echo "Install it with: flatpak install flathub org.gtk.Gtk3theme.Breeze"
        exit 1
    fi

    # Global (all apps) user override; per-app overrides don't reliably stick
    for fs in {{ gtk_theme_filesystems }}; do
        flatpak override --user --filesystem="${fs}"
    done

    config="${XDG_CONFIG_HOME:-${HOME}/.config}"
    for dir in gtk-3.0 gtk-4.0; do
        css="${config}/${dir}/gtk.css"
        mkdir -p "${config}/${dir}"
        touch "${css}"
        for import in colors.css window_decorations.css; do
            line="@import '${import}';"
            if ! grep -qxF "${line}" "${css}"; then
                echo "Adding ${line} to ${css}"
                echo "${line}" >> "${css}"
            fi
        done
    done

    theme="$(sed -n 's/^gtk-theme-name=//p' "${config}/gtk-3.0/settings.ini" 2> /dev/null || true)"
    if [ "${theme}" != "Breeze" ] || [ ! -f "${config}/gtk-3.0/colors.css" ]; then
        echo
        echo "Set the GTK theme to Breeze first: System Settings > Colors & Themes >"
        echo "Application Style > Configure GNOME/GTK Application Style... > Breeze."
    fi

    echo
    echo "Done. Fully restart Flatpak apps (or log out) to apply."
    echo "If an app still ignores it, reset its own overrides (e.g. in Flatseal):"
    echo "  flatpak override --user --reset <app-id>"

# Remove the global Flatpak override added by enable-flatpak-breeze-theme
remove-flatpak-breeze-theme:
    #!/usr/bin/bash
    set -euo pipefail

    file="${XDG_DATA_HOME:-${HOME}/.local/share}/flatpak/overrides/global"
    if [ ! -f "${file}" ]; then
        echo "No global Flatpak override found."
        exit 0
    fi

    for fs in {{ gtk_theme_filesystems }}; do
        sed -i -e "s#${fs};##g" "${file}"
    done
    sed -i -e '/^filesystems=$/d' "${file}"

    echo "Global GTK theme override removed. The ~/.config/gtk-*/gtk.css imports were left in place"
    echo "(they're what Plasma writes there itself)."
