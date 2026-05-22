# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# EXPORTS
## Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

## Some essentials
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export KEYTIMEOUT=1
export FZF_DEFAULT_OPTS='--bind=tab:down,shift-tab:up'
export _ZO_DOCTOR=0

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"
# %R is the suggested correction, %r is the original typo

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker docker-compose aws)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.

bindkey -v

autoload -U compinit && compinit
autoload -U colors && colors
autoload -Uz bashcompinit && bashcompinit
autoload -U add-zsh-hook

zstyle ':completion:*' menu select

setopt auto_menu menu_complete

source <(fzf --zsh)

# ALIASES
alias ls='eza --icons --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -lha --icons --group-directories-first'
alias tree='eza --tree --icons'
alias cat='bat --paging=never'
alias rm='trash-put' # Safe rm
alias c='printf "\e[H\e[2J"'
alias scv='source .venv/bin/activate' # source python enviroment
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

## Core programs aliases
alias v='vimx'
alias py='python3'
alias mk='make'
alias nv='nvim'

## Tmux
alias t='tmux'
alias tl='tmux ls'
alias tk='tmux kill-session -t'
alias tks='tmux kill-server'
alias ta='tmux attach'

## Docker
alias d='docker'
alias dp='docker ps --format "table {{.Status}}\t{{.ID}}\t{{.Names}}"'
alias dpp='docker ps --format "table {{.Status}}\t{{.ID}}\t{{.Names}}\t{{.Ports}}"'
alias dpa='docker ps -a --format "table {{.Status}}\t{{.ID}}\t{{.Names}}"'
alias dl='docker logs'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcub='docker compose up --build'
alias dcd='docker compose down'

## Git
### Note: Some are already defined by the plugin, but I put them here to be visible easily
alias gs='git status -s'
alias gss='git status'
alias gc='git commit -m'
alias gp='git push'
alias gsh='git stash'
alias gl='git pull'
alias glm='git pull origin $(git_main_branch)'
alias gk='git checkout'
alias glgg='git log --oneline --graph --all --decorate'
alias gdff='git diff --output-indicator-new='+' --output-indicator-old='-''
alias lg='lazygit'

## Alert for long-running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Global alias
alias -g J='| jq'
alias -g C='| wl-copy'

# HOOKS
_auto_venv() {
  if [[ -d ".venv" && -f ".venv/bin/activate" ]]; then
    source .venv/bin/activate
  elif [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate
  fi
}

# HOOKS DEFS
add-zsh-hook chpwd _auto_venv

# Custom Functions
function _launch_claude_code() {
	claude
	zle reset-prompt
}
function _clear_prompt() {
	clear
	zle reset-prompt
}

zle -N _launch_claude_code
zle -N _clear_prompt

# Bindkeys
bindkey '^Xc' _launch_claude_code
bindkey '^Xx' _clear_prompt
bindkey '^[[C' autosuggest-accept
bindkey '^[[1;5C' forward-word

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.cargo/bin:$PATH"

[ -f "/home/carburauto/.ghcup/env" ] && . "/home/carburauto/.ghcup/env" # ghcup-env

# sentry
fpath=("/home/carburauto/.local/share/zsh/site-functions" $fpath)

# zoxide
eval "$(zoxide init zsh --cmd cd)"
