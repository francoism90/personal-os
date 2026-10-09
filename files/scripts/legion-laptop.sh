#!/usr/bin/env bash
# Builds the out-of-tree legion_laptop kernel module (LenovoLegionLinux) for the image's kernel.
# Replaces DKMS, which can't build inside an image. The module is signed with our own MOK key
# (the KMOD_SIGNING_KEY secret, mounted by lenovo.yml) so it loads with Secure Boot enabled once
# the public certificate is enrolled; see recipes/base/lenovo.yml.
set -oue pipefail

SIGNING_KEY=/tmp/kmod-signing.key
SIGNING_CERT=/usr/share/legion-laptop/legion-mok.der

# francoism90/LenovoLegionLinux fork (adds the Yoga Pro 7 14AHP9 / NCCN allowlist entry).
# Pinned for reproducible builds; bump to pick up new commits.
REPO=https://github.com/francoism90/LenovoLegionLinux.git
COMMIT=bcba702d61135cd01d0086bc4f3bd183755ce75c

KVER=$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core | head -n1)
echo "Building legion_laptop for kernel ${KVER}"

# Remember what's installed, so only the build-only packages get removed afterwards.
rpm -qa --qf '%{NAME}\n' | sort -u >/tmp/rpms-before

# kernel-devel must match the image's kernel exactly. Fall back to Koji when the
# repos have already moved on to a newer kernel.
if ! dnf -y install gcc make elfutils-libelf-devel "kernel-devel-${KVER}"; then
    VER=${KVER%%-*}
    REL=${KVER#*-}
    REL=${REL%.*}
    ARCH=${KVER##*.}
    dnf -y install gcc make elfutils-libelf-devel \
        "https://kojipkgs.fedoraproject.org/packages/kernel/${VER}/${REL}/${ARCH}/kernel-devel-${KVER}.rpm"
fi

SRC=$(mktemp -d)
git clone --quiet "${REPO}" "${SRC}"
git -C "${SRC}" checkout --quiet "${COMMIT}"

make -C "/usr/src/kernels/${KVER}" M="${SRC}/kernel_module" modules

# Without the secret (e.g. not set yet) the module is still built, but only loads with Secure Boot off.
if [[ -s "${SIGNING_KEY}" ]]; then
    "/usr/src/kernels/${KVER}/scripts/sign-file" sha256 "${SIGNING_KEY}" "${SIGNING_CERT}" \
        "${SRC}/kernel_module/legion-laptop.ko"
    echo "Signed legion-laptop.ko with ${SIGNING_CERT}"
else
    echo "WARNING: KMOD_SIGNING_KEY not available, legion-laptop.ko is NOT signed" >&2
fi

install -D -m 0644 "${SRC}/kernel_module/legion-laptop.ko" \
    "/usr/lib/modules/${KVER}/extra/legion-laptop/legion-laptop.ko"
depmod -a "${KVER}"

# Clean up: sources and the build-only packages.
rm -rf "${SRC}"
rpm -qa --qf '%{NAME}\n' | sort -u >/tmp/rpms-after
comm -13 /tmp/rpms-before /tmp/rpms-after | xargs -r dnf -y remove
rm -f /tmp/rpms-before /tmp/rpms-after
