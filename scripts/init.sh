#!/bin/bash

set -e

PYTHON_VERSION="$(cat .python-version)"

echo "[i] Ask for sudo password"
sudo -v

# Environment variables
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

case "$(uname -s)" in
    Darwin)
        eval "$(/opt/homebrew/bin/brew shellenv)" > /dev/null 2>&
        # Install gcc
        if [[ ! -x /usr/bin/gcc ]]; then
          echo "[i] Install macOS Command Line Tools"
          xcode-select --install
        fi

        # Install homebrew
        if [[ ! -x /usr/local/bin/brew ]]; then
          echo "[i] Install Homebrew"
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        eval "$(/opt/homebrew/bin/brew shellenv)"
        brew update
        brew install openssl readline sqlite3 xz zlib

        # Install pyenv
        if [[ ! -x /usr/local/bin/pyenv ]]; then
          echo "[i] Install pyenv"
          brew install pyenv
        fi

        OS="darwin"
        ;;

    Linux)
        if [ -f /etc/os-release ]
            then
                . /etc/os-release

                case "$ID" in
                    debian | ubuntu)
                        # Install pyenv
                        if ! pyenv --version > /dev/null 2>&1; then
                          echo "[i] installing pyenv"
                          sudo apt-get update
                          sudo apt-get install -y build-essential curl zlib1g-dev make libssl-dev \
                            libbz2-dev libreadline-dev libsqlite3-dev wget llvm \
                            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
                          curl https://pyenv.run | bash
                        else
                          echo "[i] pyenv is already installed, skipping installation"
                        fi

                        OS="linux"
                        ;;
                    *)
                        echo "[!] Unsupported Linux Distribution: $ID"
                        exit 1
                        ;;
                esac
            else
                echo "[!] Unsupported Linux Distribution"
                exit 1
            fi
        ;;

    *)
        echo "[!] Unsupported OS"
        exit 1
        ;;
esac

# Install Python
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

echo "N" | pyenv install ${PYTHON_VERSION} || true

if [[ "$(python --version)" != "Python ${PYTHON_VERSION}" ]]; then
  echo "[e] different python version is found, exiting.."
  exit 1
fi

python --version

if [ ! -d ".venv" ]; then
  echo "[i] installing venv"
  python -m venv .venv
else
  echo "[i] venv already exists, skipping creating venv"
fi

if ! .venv/bin/ansible --version > /dev/null 2>&1; then
  echo "[i] installing ansible"
  ./.venv/bin/pip install -r requirements.txt
else
  echo "[i] ansible is already installed, skipping installation"
fi

./.venv/bin/ansible --version
./.venv/bin/ansible-galaxy install -r requirements.yaml

if [ -f "$HOME/.bashrc" ] && [ ! -h "$HOME/.bashrc" ]
then
    echo "[i] Move current ~/.bashrc to ~/.bashrc_original"
    mv "$HOME/.bashrc" "$HOME/.bashrc_original"
fi

if [ -f "$HOME/.bash_profile" ] && [ ! -h "$HOME/.bash_profile" ]
then
    echo "[i] Move current ~/.bash_profile to ~/.bash_profile_original"
    mv "$HOME/.bash_profile" "$HOME/.bash_profile_original"
fi

# Run main playbook
echo "[i] Run Playbook"
./.venv/bin/ansible-playbook ./ansible/dotfiles-${OS}.yaml --ask-become-pass

echo "[i] From now on you can use $ dotfiles to manage your dotfiles"
echo "[i] Done."
