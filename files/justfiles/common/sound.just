install-easyeffects-presets:
    #!/usr/bin/bash
    set -euo pipefail

    bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/EasyEffects-Presets/master/install.sh)"

remove-easyeffects-presets:
    #!/usr/bin/bash
    set -euo pipefail

    if [ -d "${HOME}/.var/app/com.github.wwmm.easyeffects" ]; then
        config_dir="${HOME}/.var/app/com.github.wwmm.easyeffects/config/easyeffects"
    else
        config_dir="${HOME}/.config/easyeffects"
    fi

    rm -rf "${config_dir}/output" "${config_dir}/irs"
