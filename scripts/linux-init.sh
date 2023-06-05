#!/bin/bash

set -e

PYTHON_VERSION="$(cat .python-version)"

echo "[i] Ask for sudo password"
sudo -v

if [[ $(uname -s) != "Linux" ]]; then
  echo "[e] Not a `Linux` distribution, please choose another script"
  exit 1
fi

# Install pyenv
if ! pyenv --version > /dev/null 2>&1; then
  echo "[i] installing pyenv"
  sudo apt-get update
  sudo apt-get install curl -y 
  curl https://pyenv.run | bash
else
  echo "[i] pyenv is already installed, skipping installation"
fi

# Exec pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
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
ansible-playbook ./ansible/dotfiles-linux.yaml --ask-become-pass

echo "[i] From now on you can use $ dotfiles to manage your dotfiles"
echo "[i] Done."