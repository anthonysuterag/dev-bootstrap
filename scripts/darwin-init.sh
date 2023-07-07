#!/bin/bash

set -e

PYTHON_VERSION="$(cat .python-version)"

echo "[i] Ask for sudo password"
sudo -v

if [[ $(uname -s) != "Darwin" ]]; then
  echo "[e] Not a `Darwin` distribution, please choose another script"
  exit 1
fi

# Install gcc
if [[ ! -x /usr/bin/gcc ]]; then
  echo "[i] Install macOS Command Line Tools"
  xcode-select --install
fi

# Install homebrew
if [[ ! -x /usr/local/bin/brew ]]; then
  echo "[i] Install Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew update
fi

# Install pyenv
if [[ ! -x /usr/local/bin/pyenv ]]; then
  echo "[i] Install pyenv"
  brew install pyenv
fi

# Exec pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
exec "$SHELL"
