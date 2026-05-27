#!/usr/bin/env bash
set -euo pipefail

exec "$(dirname "$0")/tool/pulsepanel_deploy.sh" "$@"
