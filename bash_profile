# Source other bash files
if [ -f ~/.bashrc_original ] ; then
  . ~/.bashrc_original
fi
if [ -f ~/.bash_profile ] ; then
  . ~/.bashrc
fi
if [ -f ~/.bashrc_local ] ; then
  . ~/.bashrc_local
fi

export PATH=/usr/local/bin:$PATH

# Direnv
eval "$(direnv hook bash)"

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"

# pyenv config
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# kubectl
source <(kubectl completion bash)

# tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

# Starship
eval "$(starship init bash)"

# Brew
if [[ $(uname -s) == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Aliases
alias k='kubectl'
