# personal-os &nbsp; [![bluebuild build badge](https://github.com/francoism90/personal-os/actions/workflows/build.yml/badge.svg)](https://github.com/francoism90/personal-os/actions/workflows/build.yml)

Custom [BlueBuild](https://blue-build.org/) images, built from the recipes in [`recipes/`](recipes/). Each recipe publishes its own image to `ghcr.io/francoism90/<recipe-name>`.

## Images

- `kinoite-nvidia-open` — Fedora Kinoite on `ghcr.io/ublue-os/kinoite-nvidia` ([`recipes/recipe-kinoite-nvidia-open.yml`](recipes/recipe-kinoite-nvidia-open.yml))

## Installation

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

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/francoism90/<image>
```
