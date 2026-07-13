#!/bin/sh
#
# Sync local seedsigner working tree to a pi0 dev device over ssh.
# The device runs the app from /mnt/data/seedsigner/src/main.py.
#
# ---------------------------------------------------------------------------
# One-time connectivity setup (run on your Mac):
#
# 1. Add an SSH keypair to the pi0's authorized_keys (default root
#    password is "seedsigner"):
#      ssh root@seedsigner.local "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
#      cat ~/.ssh/id_ed25519.pub | ssh root@seedsigner.local \
#          "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
#
# 2. (Optional) Add a Host entry to ~/.ssh/config for a short "seedsigner"
#    alias and to silence host-key prompts across device re-flashes:
#      Host seedsigner seedsigner.local
#          HostName seedsigner.local
#          User root
#          StrictHostKeyChecking no
#          UserKnownHostsFile /dev/null
#          LogLevel ERROR
#
# 3. Test passwordless login:
#      ssh seedsigner.local
# ---------------------------------------------------------------------------

set -eu

HOST="${SEEDSIGNER_HOST:-seedsigner.local}"
USER="${SEEDSIGNER_USER:-root}"
DEST_DIR="/mnt/data/seedsigner"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RESTART=""
for arg in "$@"; do
    case "$arg" in
        --restart)
            RESTART="1"
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

rsync -avz --delete \
    --exclude 'rsync-to-seedsigner.sh' \
    --exclude '.git/' \
    --exclude '.DS_Store' \
    --exclude '__pycache__/' \
    --exclude '*.pyc' \
    --exclude 'enclosures/' \
    --exclude 'venv/' \
    --exclude '.venv/' \
    --exclude 'seedsigner-screenshots/' \
    --exclude 'coverage_html_report/' \
    "$SCRIPT_DIR/" "$USER@$HOST:$DEST_DIR/"

if [ -n "$RESTART" ]; then
    ssh "$USER@$HOST" "seedsigner restart"
fi
