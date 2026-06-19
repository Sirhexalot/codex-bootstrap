#!/usr/bin/env bash
set -euo pipefail

echo "Richte die globale Codex-Werkbank auf macOS ein."
echo "Dieses Skript installiert nur allgemeine Werkzeuge."
echo "Es installiert kein Codex, keine Skills und keine projektbezogenen Dateien."
echo

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew wurde nicht gefunden. Installation wird gestartet ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "Aktualisiere Homebrew ..."
brew update

echo "Installiere globale Werkbank-Tools ..."
brew install python python@3.13 node ffmpeg imagemagick ghostscript curl git pipx

echo "Installiere globale npm-Werkzeuge ..."
npm install -g pnpm playwright
npx -y playwright install

echo "Installiere optionale globale CLI-Werkzeuge ..."
python3 -m pip install --upgrade pip
pipx ensurepath >/dev/null 2>&1 || true

if command -v python3.13 >/dev/null 2>&1; then
  if python3.13 -m pip index versions meta-ads >/dev/null 2>&1; then
    pipx install --force --python "$(command -v python3.13)" meta-ads || true
  fi
fi

echo
echo "Fertig."
echo "Versionen:"
python3 --version || true
node --version || true
npm --version || true
ffmpeg -version | head -n 1 || true
magick --version | head -n 1 || true
gs --version || true
