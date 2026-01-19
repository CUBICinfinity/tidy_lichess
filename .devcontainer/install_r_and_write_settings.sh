#!/usr/bin/env bash
set -e

# Try to find R
R_PATH="$(command -v R || true)"

# If not found, attempt to install via apt (fallback; image build should have installed R)
if [ -z "$R_PATH" ]; then
  if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends r-base
    R_PATH="$(command -v R || true)"
  else
    echo "R not found and no apt available; please ensure R is installed in the container." >&2
    exit 0
  fi
fi

if [ -z "$R_PATH" ]; then
  echo "R not found after install attempt; aborting settings write." >&2
  exit 0
fi

mkdir -p .vscode
cat > .vscode/settings.json <<EOF
{
  "r.rterm.linux": "$R_PATH",
  "r.rpath.linux": "$R_PATH",
  "terminal.integrated.profiles.linux": {
    "R": {
      "path": "$R_PATH",
      "args": ["--no-save", "--no-restore"]
    }
  }
}
EOF

echo "Wrote .vscode/settings.json with R at $R_PATH"
