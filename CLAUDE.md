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
  over `recipes/recipe-*.yml` (currently just `recipe-kinoite-nvidia-open.yml`). Triggers: push (except
  docs-only changes), pull_request, a daily 06:00 UTC schedule, and manual `workflow_dispatch`.
- Images are signed with cosign; the public key lives at `cosign.pub`, the private key is the
  `SIGNING_SECRET` GitHub Actions secret. Never commit `cosign.key`/`cosign.private` (already gitignored).
- The only real way to verify a change "works" is to open a PR and let CI build the image, or read the
  BlueBuild module schema/docs for the module types used.

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
  - `desktop.yml` — desktop-environment-agnostic tweaks (currently: dnf install/remove).
  - `kinoite.yml` — KDE/Kinoite-specific bits, currently `default-flatpaks` (system + user scope).
- `modules/` — reserved for custom BlueBuild module definitions; currently empty (only `.gitkeep`).
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
