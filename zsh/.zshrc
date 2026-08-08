# CachyOS base config
# if [[ -f /usr/share/cachyos-zsh-config/cachyos-config.zsh ]]; then
#     source /usr/share/cachyos-zsh-config/cachyos-config.zsh
# fi

export ZSH="/usr/share/oh-my-zsh"
plugins=(git fzf extract)
source $ZSH/oh-my-zsh.sh

fastfetch --config ~/.config/fastfetch/config.jsonc

export HISTCONTROL=ignoreboth
export HISTORY_IGNORE="(\&|[bf]g|c|clear|history|exit|q|pwd|* --help)"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"

export FZF_BASE=/usr/share/fzf

export LS_COLORS="$(vivid generate one-dark)"
alias ls="eza -l --icons=always --color=always --group-directories-first"
alias ll="eza -la --icons=always --color=always --group-directories-first"
alias make="make -j$(nproc)"
alias ninja="ninja -j$(nproc)"
# alias n="nvim"
# alias c="clear"
# alias update="sudo pacman -Syu"
# alias cleanup="sudo pacman -Rsn $(pacman -Qtdq)"
alias jctl="journalctl -p 3 -xb"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

# alias to enter Hermes TUI which resides inside a docker container
alias hermes="docker exec -it hermes /opt/hermes/.venv/bin/hermes"

# Disable XON/XOFF so Ctrl+S works in Neovim
stty -ixon

tailscale() {
    if [[ " $* " =~ " down " ]]; then
        echo "tailscale down = lose ssh remote access"
        echo -n "Type 'I understand' to proceed: "
        read confirm
        if [[ "$confirm" != "I understand" ]]; then
            echo "Aborted."
            return 1
        fi
    fi
    command tailscale "$@"
}

zstyle ':completion:*' menu select
setopt AUTO_CD
setopt AUTO_LIST
setopt EXTENDED_GLOB
setopt NO_BEEP
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'

setopt PROMPT_SUBST
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' formats '%F{#F14E32}(%b)%f'
zstyle ':vcs_info:git*' actionformats '%F{#F14E32}(%b|%a)%f'

precmd() {
    vcs_info
}

build_prompt() {
    local p_time="%D{%H:%M:%S}"
    local p_user="%B%F{red}%n%f%b"
    local p_host="%B%F{red}%m%f%b"
    local p_cwd="%F{green}%/%f"
    local p_vcs="${vcs_info_msg_0_}"

    local p_venv=""
    if [[ -n "$VIRTUAL_ENV" ]]; then
        p_venv="%F{cyan}[$(basename "$VIRTUAL_ENV")]%f"
    fi

    local p_rust=""
    if [[ -f Cargo.toml ]]; then
        p_rust="%F{#ffa500}(Rust)%f"
    fi

    if [[ -z "$p_vcs" && -n "${p_venv}${p_rust}" ]]; then
        p_vcs=" "
    fi

    local p_extras="${p_vcs}${p_venv}${p_rust}"
    echo "[${p_time}] ${p_user}@${p_host} ${p_cwd} ${p_extras}"
}

PROMPT='$(build_prompt)
> '

if [[ -f "$HOME/.openclaw/completions/openclaw.zsh" ]]; then
    source "$HOME/.openclaw/completions/openclaw.zsh"
fi

export PATH="$HOME/.local/bin:$PATH"

# These must be loaded at the very end of the file
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/doc/pkgfile/command-not-found.zsh

# Autosuggestions (set style before sourcing)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#786D82'
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting (set styles before sourcing, then source)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fix: wrap autosuggest-accept to re-apply syntax highlighting,
# so accepted text gets proper colors instead of staying gray
autosuggest-accept() {
    zle .autosuggest-accept
    _zsh_highlight
}
zle -N autosuggest-accept

# ── zsh-syntax-highlighting ──
typeset -A ZSH_HIGHLIGHT_STYLES

# Commands & builtins (red)
ZSH_HIGHLIGHT_STYLES[command]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#ff5555,bold'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#ff5555,bold'

# Precommands & reserved words (purple)
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#B16286,underline,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#B16286'

# Strings & arguments
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#FABD2F'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#FABD2F'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#FB4934'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#FB4934'

# Paths & globbing (blue)
ZSH_HIGHLIGHT_STYLES[path]='fg=#61afef,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#61afef,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#61afef'

# Operators
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#8EC07C,bold'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#B8BB26'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#EBDBB2'

# Substitutions
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#EBDBB2'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#A89984'
ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=#EBDBB2'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#A89984'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=#EBDBB2'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#EBDBB2'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#665C54'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#FE8019'

# Misc
ZSH_HIGHLIGHT_STYLES[comment]='fg=#928474'
# ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#CC241D,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#EBDBB2'
ZSH_HIGHLIGHT_STYLES[default]='fg=#EBDBB2'

# Explicitly disable autodetect (terminal handles color itself)
ZSH_HIGHLIGHT_STYLES[autodetect]='none'
