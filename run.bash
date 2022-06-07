#!/usr/bin/env bash
set -euxo pipefail
if command -v docker &> /dev/null; then CONTAINERIZER=docker; else CONTAINERIZER=podman; fi
"${CONTAINERIZER}" build . --tag swaytest
"${CONTAINERIZER}" run --interactive --tty --rm --publish 6080:6080 --env RESOLUTION="${RESOLUTION:-"1920x1080"}" --init swaytest
