#!/bin/sh
# Run the test suite on multiple Linux/Unix distributions via Docker.
# Each distro ships a different /bin/sh, which proves the lib is portable:
#
#   alpine     → ash  (BusyBox — embedded / musl libc)
#   busybox    → ash  (standalone BusyBox)
#   debian     → dash (strict POSIX, no bashisms)
#   ubuntu     → dash (strict POSIX, no bashisms)
#   fedora     → bash (GNU coreutils)
#   opensuse   → bash (SUSE userland)
#
# Usage: sh tests/run_on_distros.sh
# Requirements: Docker daemon running

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if ! command -v docker > /dev/null 2>&1; then
    printf "ERROR: docker is required but not found in PATH\n" >&2
    exit 1
fi

# Detect native CPU architecture so Docker pulls a matching image and avoids
# the "exec /bin/sh: no such file or directory" ELF interpreter error that
# occurs when an amd64 binary runs on an arm64 kernel without QEMU binfmt.
case "$(uname -m)" in
    x86_64)        _platform="linux/amd64"  ;;
    arm64|aarch64) _platform="linux/arm64"  ;;
    *)             _platform="linux/$(uname -m)" ;;
esac

_total=0
_pass=0
_fail=0

run_on() {
    image="$1"
    _total=$((_total + 1))
    printf "%-35s " "$image"

    if output=$(docker run --rm \
        --platform "$_platform" \
        -v "$ROOT_DIR:/posix_shell_lib:ro" \
        "$image" \
        sh /posix_shell_lib/tests/run_tests.sh 2>&1); then
        _pass=$((_pass + 1))
        printf "✅ PASS\n"
    else
        _fail=$((_fail + 1))
        printf "FAIL\n"
        printf "%s\n" "$output" | sed 's/^/    /'
    fi
}

printf "Testing portability across distributions\n"
printf "=========================================\n\n"

run_on "alpine:latest"
run_on "busybox:latest"
run_on "debian:stable-slim"
run_on "ubuntu:latest"
run_on "fedora:latest"
run_on "opensuse/leap:latest"
run_on "amazonlinux:latest"

printf "\n%d/%d distributions passed\n" "$_pass" "$_total"
[ "$_fail" -eq 0 ]
