export PATH=$PATH:$(go env GOPATH)/bin
# -----------------
# History
# -----------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# -----------------
# Opts
# -----------------
setopt AUTO_CD
setopt NO_CASE_GLOB

# -----------------
# Zinit Plugin manager
# -----------------
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust


autoload -U +X compinit && compinit

# -----------------
# Zinit plugins
# -----------------

zinit ice depth=1
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light jeffreytse/zsh-vi-mode

# -----------------
# FZF
# -----------------
source <(fzf --zsh)

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi


if [ -f "$ZDOTDIR/aliases.zsh" ]; then
    source "$ZDOTDIR/aliases.zsh" 
fi

# Enable prompt substitution for dynamic variables
setopt PROMPT_SUBST

# Function to fetch tun0 IP
get_tun0_ip() {
    ip -4 addr show tun0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1
}

# Update the prompt variable before each prompt
precmd() {
    local ip
    ip=$(get_tun0_ip)
    if [[ -n "$ip" ]]; then
        # Green IP address if VPN is active
        TUN0_PROMPT="%F{green}[$ip]%f"
    else
        # Red "No VPN" if tun0 is down
        TUN0_PROMPT="%F{red}[No VPN]%f"
    fi
}

# Customize your prompt format here
PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f ${TUN0_PROMPT} %# '

