#!/usr/bin/env bash
set -euo pipefail

is_rosetta_shell() {
  [[ "$(sysctl -n sysctl.proc_translated 2>/dev/null || printf 0)" == "1" ]]
}

is_apple_silicon() {
  [[ "$(uname -m)" == "arm64" ]]
}

resolve_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    printf '%s\n' "/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    printf '%s\n' "/usr/local/bin/brew"
  elif command -v brew >/dev/null 2>&1; then
    command -v brew
  else
    return 1
  fi
}

run_brew() {
  if is_apple_silicon && [[ "$BREW_BIN" == "/opt/homebrew/bin/brew" ]]; then
    arch -arm64 "$BREW_BIN" "$@"
  else
    "$BREW_BIN" "$@"
  fi
}

run_npm() {
  if is_apple_silicon && command -v arch >/dev/null 2>&1; then
    arch -arm64 npm "$@"
  else
    npm "$@"
  fi
}

run_npx() {
  if is_apple_silicon && command -v arch >/dev/null 2>&1; then
    arch -arm64 npx "$@"
  else
    npx "$@"
  fi
}

echo "Richte die globale Codex-Werkbank auf macOS ein."
echo "Dieses Skript installiert nur allgemeine Werkzeuge."
echo "Es installiert kein Codex, keine Skills und keine projektbezogenen Dateien."
echo

if is_apple_silicon && is_rosetta_shell; then
  echo "Hinweis: Dieses Terminal läuft unter Rosetta."
  echo "Homebrew unter /opt/homebrew wird deshalb automatisch mit ARM aufgerufen."
  echo
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew wurde nicht gefunden. Installation wird gestartet ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_BIN="$(resolve_homebrew)"
eval "$("$BREW_BIN" shellenv)"

echo "Aktualisiere Homebrew ..."
run_brew update

echo "Installiere globale Werkbank-Tools ..."
run_brew install python python@3.13 node ffmpeg imagemagick ghostscript curl git pipx

echo "Installiere globale npm-Werkzeuge ..."
run_npm install -g pnpm playwright
run_npx -y playwright install

echo "Installiere optionale globale CLI-Werkzeuge ..."
pipx ensurepath >/dev/null 2>&1 || true
echo "Homebrew-Python wird nicht per pip global verändert (PEP 668)."

if command -v python3.13 >/dev/null 2>&1; then
  if python3.13 -m pip index versions meta-ads >/dev/null 2>&1; then
    PYTHON313_BIN="$(command -v python3.13)"
    if pipx list 2>/dev/null | grep -qE '(^|[[:space:]])package meta-ads '; then
      pipx reinstall --python "$PYTHON313_BIN" meta-ads || true
    else
      pipx install --python "$PYTHON313_BIN" meta-ads || true
    fi
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
