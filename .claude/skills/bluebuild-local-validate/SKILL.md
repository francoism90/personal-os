---
name: bluebuild-local-validate
description: Validate a recipe in this BlueBuild repo locally, without waiting on CI, using the bluebuild CLI if it's installed. Use when the user wants to sanity-check a recipe/module change (e.g. after editing recipes/base/*.yml or a recipe-*.yml) before pushing or opening a PR.
---

# Validating a recipe locally

This repo has no local build/lint/test command of its own — BlueBuild's own tooling is what interprets the
recipe YAML. The `bluebuild` CLI comes pre-installed on images built by BlueBuild, but is generally **not**
installed in a plain dev environment, so check first.

## Steps

1. Check whether the CLI is available: `command -v bluebuild`.
   - If missing, tell the user it's not installed and point them at the BlueBuild CLI repo
     (https://github.com/blue-build/cli) for install options, or suggest skipping straight to opening a PR
     and letting CI build it (the normal path per `CLAUDE.md`). Don't attempt to install it yourself unless
     the user asks — installing a CLI tool system-wide is their call.

2. If available, render the Containerfile without building (fast, good for spot-checking a module's output):
   ```
   bluebuild generate ./recipes/recipe-<name>.yml -o Containerfile
   ```
   `Containerfile` is gitignored (`/Containerfile`) — never commit it. Read the relevant section of the
   generated file to confirm the module(s) you changed produced what you expect.

3. For a full local build (slow; needs podman/docker and real disk space):
   ```
   bluebuild build ./recipes/recipe-<name>.yml
   ```

4. To actually deploy a locally-built image to a running Fedora Atomic system, `bluebuild switch
   ./recipes/recipe-<name>.yml` exports and rebases onto it via `rpm-ostree` — this is a real, hard-to-reverse
   system change, so only run it if the user explicitly asks to switch their own machine, never as a
   "just to test" step.

5. Remember this never validates everything CI does: image signing (cosign), the multi-recipe build matrix,
   and multi-arch builds only happen in `.github/workflows/build.yml`. A clean local `generate`/`build` is a
   good sanity check, not a substitute for a CI run before merging.
