---
name: bluebuild-new-recipe
description: Scaffold a new BlueBuild image in this repo (new recipes/recipe-*.yml, base fragment if needed, and CI matrix entry). Use whenever the user wants to add a new image variant (e.g. a new desktop environment or base image combination) to this recipe repository.
---

# Adding a new BlueBuild image

This repo publishes one container image per `recipes/recipe-*.yml` file. A recipe alone is never built —
it must also be registered in the CI matrix. Follow all steps; skipping the matrix entry is the most common
mistake (see `CLAUDE.md`'s "Adding a new image" section).

## Steps

1. **Pick the base image** — find the right `ghcr.io/blue-build/base-images/...` image for the desired
   Fedora Atomic variant (e.g. `fedora-kinoite`, `fedora-cosmic-nvidia-open`). Check
   https://github.com/orgs/blue-build/packages if unsure what's available.

2. **Create `recipes/recipe-<name>.yml`**, following the existing recipes as a template:
   ```yaml
   ---
   # yaml-language-server: $schema=https://schema.blue-build.org/recipe-v1.json
   name: <name>
   description: <short description>
   base-image: ghcr.io/blue-build/base-images/<base-image>
   image-version: latest
   modules:
     - from-file: base/common.yml
     - from-file: base/desktop.yml
     - from-file: base/<desktop-environment>.yml   # only if one exists/is needed
   ```
   Compose the `modules:` list from `recipes/base/*.yml` fragments, matching how the existing recipes reuse
   `common.yml` (universal), `desktop.yml` (DE-agnostic desktop tweaks), and a DE-specific fragment
   (`kinoite.yml`, `cosmic.yml`) — don't inline modules that belong in a shared fragment.

3. **If the desktop environment has no fragment yet**, create `recipes/base/<de>.yml` as a bare `modules:`
   list (not a standalone recipe — no `name`/`base-image`/etc.), and reference it via `from-file:` from the
   new recipe.

4. **Register the recipe in CI** — add `recipe-<name>.yml` to the `matrix.recipe` list in
   `.github/workflows/build.yml`. This is not optional; without it the image never builds, signs, or
   publishes.

5. **Update `README.md`'s Images list** with the new image name and a link to its recipe file, matching the
   existing table format.

6. **Validate** — there's no full local build, but you can sanity-check the recipe renders correctly if the
   `bluebuild` CLI is available (see the `bluebuild-local-validate` skill). Otherwise, open a PR and let CI
   build it.
