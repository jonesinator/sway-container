#!/usr/bin/env bash
set -euxo pipefail
sd __RESOLUTION__ "${RESOLUTION}" ~/.config/sway/config
exec sway
