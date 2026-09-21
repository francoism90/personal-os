# personal-os &nbsp; [![bluebuild build badge](https://github.com/francoism90/personal-os/actions/workflows/build.yml/badge.svg)](https://github.com/francoism90/personal-os/actions/workflows/build.yml)

Custom [BlueBuild](https://blue-build.org/) images, built from the recipes in [`recipes/`](recipes/). Each recipe publishes its own image to `ghcr.io/francoism90/<recipe-name>`.

## Images

- `kinoite-nvidia-open` — Fedora Kinoite based on `ghcr.io/blue-build/base-images/fedora-kinoite-nvidia-open` ([`recipes/recipe-kinoite-nvidia-open.yml`](recipes/recipe-kinoite-nvidia-open.yml))
- `cosmic-nvidia-open` — Fedora COSMIC based on `ghcr.io/blue-build/base-images/fedora-cosmic-nvidia-open` ([`recipes/recipe-cosmic-nvidia-open.yml`](recipes/recipe-cosmic-nvidia-open.yml))
- `cosmic-nightly-nvidia-open` — same as `cosmic-nvidia-open`, but with the COSMIC desktop from the [`ryanabx/cosmic-epoch`](https://copr.fedorainfracloud.org/coprs/ryanabx/cosmic-epoch/) COPR ([`recipes/recipe-cosmic-nightly-nvidia-open.yml`](recipes/recipe-cosmic-nightly-nvidia-open.yml))
- `ucore` — headless Fedora CoreOS based on [`ghcr.io/ublue-os/ucore`](https://github.com/ublue-os/ucore), which includes ZFS ([`recipes/recipe-ucore.yml`](recipes/recipe-ucore.yml))

The `ucore` image loads the ZFS module at boot (`files/core/etc/modules-load.d/zfs.conf`). With Secure Boot enabled, first enroll the uBlue signing key with `sudo mokutil --import /etc/pki/akmods/certs/akmods-ublue.der`, otherwise the module won't load. `/` is immutable, so create pools with an explicit mountpoint under `/var`, e.g. `zpool create -m /var/tank tank /dev/sdb`.

> [!WARNING]
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build, substitute `<image>` below with the image name from the [Images](#images) list (e.g. `kinoite-nvidia-open`):

- First rebase to the unsigned image, to get the proper signing keys and policies installed:

  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/francoism90/<image>:latest
  ```

- Reboot to complete the rebase:

  ```
  systemctl reboot
  ```

- Then rebase to the signed image, like so:

  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/francoism90/<image>:latest
  ```

- Reboot again to complete the installation

  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in the recipe's `image-version`, so you won't get accidentally updated to the next major version.

### Switching between images

If you're already running one of these (signed) images, the signing keys and policies are in place, so you can skip the unsigned rebase and switch directly with `bootc`, e.g. from `cosmic-nightly-nvidia-open` to `kinoite-nvidia-open`:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/francoism90/<image>:latest
systemctl reboot
```

`--enforce-container-sigpolicy` makes bootc verify the image signature against `/etc/containers/policy.json`; without it, no signature check is done. Add `--apply` to reboot automatically. The previous deployment is kept, so `sudo bootc rollback` (followed by a reboot) takes you back. `/var` and `/etc` carry over, so your home directory and user-scope Flatpaks stay, but desktop-specific config (e.g. `~/.config/cosmic`) is left unused.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/francoism90/<image>
```
