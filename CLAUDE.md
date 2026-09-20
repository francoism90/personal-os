# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a [BlueBuild](https://blue-build.org/) recipe repository, not an application. It declaratively
describes a custom Fedora Atomic (Kinoite) OCI image — there is no app code to run, build, or unit test
locally. "Building" means BlueBuild's tooling interprets the recipe/module YAML and produces a container
image; that only happens in CI (or manually via the `bluebuild` CLI, which is not installed in this repo).

## Building / validating changes

- There is no local build, lint, or test command in this repo. Recipe YAML is validated by BlueBuild
  itself at build time (e.g. the `justfiles` module below has `validate: true`, which checks `just`
  syntax during the build).
- Builds run via `.github/workflows/build.yml`, using the reusable `blue-build/github-action`, matrixed
  over `recipes/recipe-*.yml` (currently `recipe-kinoite-nvidia-open.yml`,
  `recipe-cosmic-nvidia-open.yml`, `recipe-cosmic-nightly-nvidia-open.yml` and `recipe-ucore.yml`). Triggers: push (except docs-only changes), pull_request, a daily
  06:00 UTC schedule, and manual `workflow_dispatch`.
- Images are signed with cosign; the public key lives at `cosign.pub`, the private key is the
  `SIGNING_SECRET` GitHub Actions secret. Never commit `cosign.key`/`cosign.private` (already gitignored).
- The only real way to fully verify a change "works" is to open a PR and let CI build the image, or read the
  BlueBuild module schema/docs for the module types used.
- If the `bluebuild` CLI happens to be installed, you can validate a recipe without CI:
  `bluebuild generate ./recipes/recipe-<name>.yml -o Containerfile` renders the Containerfile (gitignored)
  so you can eyeball what a module produces, and `bluebuild build ./recipes/recipe-<name>.yml` does a full
  local build (needs podman/docker). Neither replaces CI — signing and the matrix only run there. See the
  `bluebuild-local-validate` skill.

## Adding a new image

New images = new `recipes/recipe-*.yml` file **and** a matching entry added to the `matrix.recipe` list in
`.github/workflows/build.yml` (both steps are required; a recipe file alone never gets built). If the image
needs its own desktop-specific tweaks, add a fragment under `recipes/base/` and reference it via `from-file:`
the same way `kinoite.yml`/`cosmic.yml` do. See the `bluebuild-new-recipe` skill for the scaffolding steps.

## Architecture

- `recipes/recipe-*.yml` — top-level, buildable recipes (one per published image). Each sets
  `base-image`, `image-version`, and composes its `modules:` list mostly via `from-file:` includes
  pointing into `recipes/base/`. New images = new `recipe-*.yml` file + a matching entry added to the
  `matrix.recipe` list in `.github/workflows/build.yml`.
- `recipes/base/*.yml` — reusable module fragments shared across recipes, each just a `modules:` list
  fragment (not standalone recipes). Current split:
  - `common.yml` — applies to every image: the `files` module (see below), fish/starship via a copr,
    common CLI packages (btrfsmaintenance, hdparm, lm_sensors, rclone, rsync), and the `justfiles`
    module that wires up `ujust` recipes.
  - `core.yml` — headless uCore (Fedora CoreOS) bits, used by `recipe-ucore.yml` on top of `common.yml`:
    the `files` module for the `files/server/` overlay (kept apart from `files/system` so desktop images
    don't get it), currently just `etc/modules-load.d/zfs.conf`, since uCore ships the signed ZFS kmod but
    doesn't auto-load it.
  - `desktop.yml` — desktop-environment-agnostic tweaks: the terra repo (`terra-release`, Nerd fonts; must
    come before `cosmic.yml`, which installs from it), dnf install/remove, `default-flatpaks` (Flathub
    apps, plus a second `system`-scope `flatpaks` remote for the custom Flatpaks), and `kargs`. The custom
    Flatpaks (`com.visualstudio.code`, `ai.claude.desktop`, `org.freedesktop.Sdk.Extension.podman`) are
    built and signed in a separate repo, [`francoism90/flatpaks`](https://github.com/francoism90/flatpaks),
    and published to `https://francoism90.github.io/flatpaks/index.flatpakrepo`. This repo only consumes
    that remote, so adding or updating one of those apps never touches the image recipes. Keep that block
    after the Flathub one, because the apps' runtimes come from Flathub.
  - `kinoite.yml` — KDE/Kinoite-specific bits, currently `default-flatpaks` (system + user scope).
  - `cosmic.yml` — COSMIC-specific bits: `dnf` install of the terrapkg COSMIC desktop extras (each
    subdirectory under `anda/desktops/cosmic` in `terrapkg/packages` is its own package, not one bundle),
    plus `default-flatpaks` (GTK/libcosmic-friendly Flathub apps, and a `system`-scope `cosmic` repo
    pointing at `https://apt.pop-os.org/cosmic/cosmic.flatpakrepo`).
- `modules/` — reserved for custom BlueBuild module definitions; currently empty (only `.gitkeep`). A custom
  module lives at `modules/<name>/<name>.sh` (dash-separated name = the `type:` used in recipes); the script
  gets its module config as a JSON string in `$1`, must exit non-zero on failure (build fails with it), and
  automatically overrides any built-in module of the same name — no registration step needed.
- `files/system/` — a literal overlay of the target image's root filesystem. Anything under
  `files/system/<path>` is copied to `/<path>` in the built image via the `files` module in
  `common.yml` (`source: system`, `destination: /`).
- `files/scripts/` — shell scripts intended to be run during the build by a recipe's `script` module.
  Convention (see `files/scripts/example.sh`): start with `set -oue pipefail` so the build fails loudly
  on any error.
- `files/justfiles/*.just` — `just` recipes that become `ujust <recipe-name>` commands inside the built
  image. Wired up via `type: justfiles` modules' `include:` list (see `common.yml`). **Important**:
  `include:` entries are matched by filename against this local directory *first*, falling back to the
  community justfiles collection (ublue-os/bling) if not found locally — this is why entries like
  `common` and `gnome/monitors.just` resolve correctly even though no such files exist in this repo. A
  local file with multiple `just` recipes in it is pulled in as one `include:` entry (by filename) and
  all recipes inside it become available.

## Signing (cosign)

- The keypair was generated once with `cosign generate-key-pair` (passphrase left empty — an encrypted key
  doesn't work in the unattended GitHub Actions signing step). `cosign.pub` is committed at the repo root;
  the private key is never committed (see `.gitignore`) and instead lives only as the `SIGNING_SECRET`
  repo secret (`gh secret set SIGNING_SECRET < cosign.key`), which the `blue-build/github-action` step in
  `build.yml` consumes as `cosign_private_key`.
- Rotating the key means regenerating the pair, replacing the committed `cosign.pub`, and updating
  `SIGNING_SECRET` — old images signed with the previous key won't verify against the new `cosign.pub`.
- End users verify an image with `cosign verify --key cosign.pub ghcr.io/francoism90/<image>` (documented in
  `README.md`).

## Syncing upstream template changes

This repo started from `blue-build/template`. It's rarely needed, but if the template gains a feature worth
pulling in: `git remote add template https://github.com/blue-build/template.git`, `git fetch --all`, then
`git merge template/main --allow-unrelated-histories` (do this on a throwaway branch first). Expect conflicts
in `config/`, `files/`, `recipes/`, `modules/`, `README.md`, and `cosign.pub` — those are this repo's own
customizations, so resolve in favor of what's already here unless the template change is clearly wanted.

## Reference docs

- Recipe schema: https://blue-build.org/reference/recipe/
- Module reference (all built-in module types): https://blue-build.org/reference/module/
- Writing a custom module: https://blue-build.org/how-to/making-modules/
- Multiple images in one repo: https://blue-build.org/how-to/multiple-images/
- Local builds with the `bluebuild` CLI: https://blue-build.org/how-to/local/
- Cosign / signing: https://blue-build.org/how-to/cosign/
- Syncing template updates: https://blue-build.org/how-to/sync/
