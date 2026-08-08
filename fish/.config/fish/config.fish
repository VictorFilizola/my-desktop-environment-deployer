# ── Dependencies ────────────────────────────────
#   Needed for full experience (install if missing):
#     vivid   — LS_COLORS generator       (pacman -S vivid)
#     eza     — ls/ll replacement         (pacman -S eza)
#     fastfetch — welcome screen           (pacman -S fastfetch)
#   Config companion file:
#     ~/.config/fish/my_colors.fish  — all theme colors
#
# ── CachyOS base config ─────────────────────────
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# This overrides the CachyOS greeting with your preferred fastfetch
function fish_greeting
    fastfetch --config ~/.config/fastfetch/config.jsonc
end

# Otherwise, just use this command to execute standart fastfetch
#fastfetch

# Load custom fish colors at the file my_colors.fish (needs to be created)

if status is-interactive
    # Load custom terminal and theme colors
    source ~/.config/fish/my_colors.fish
end

# Color files according to their type. Needs "vivid" and "eza"
# sudo pacman -S vivid eza
if status is-interactive
    # Generate distinct text colors for every file extension using the 'one-dark' theme
    set -gx LS_COLORS (vivid generate one-dark)

    # Use eza with the long-list layout (-l), icons, and explicit color rendering
    alias ls="eza -l --icons=always --color=always --group-directories-first"
    alias ll="eza -la --icons=always --color=always --group-directories-first"
end
export PATH="$HOME/.local/bin:$PATH"

# Guard against accidental 'tailscale down' — kills remote SSH access
function tailscale --wraps=tailscale
    if contains -- down $argv
        echo "⚠️  tailscale down = LOSE SSH ACCESS from remote."
        echo "    Server at home, will only get on manually."
        read -P "Type 'I understand' to proceed: " confirm
        if test "$confirm" != "I understand"
            echo "Aborted."
            return 1
        end
    end
    command tailscale $argv
end

# Prompt with time, user@host (bold red), path (green), git branch
function fish_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status

    # Force Git branch to use parentheses instead of brackets and set color to #F14E32
    set -g __fish_git_prompt_prefix "("
    set -g __fish_git_prompt_suffix ")"
    set -g __fish_git_prompt_color_branch F14E32
    set -g __fish_git_prompt_color_prefix F14E32
    set -g __fish_git_prompt_color_suffix F14E32
    set -g __fish_git_prompt_color F14E32

    # Extract active Python virtual environment name
    set -l venv_prompt ""
    if set -q VIRTUAL_ENV
        set -l venv_name (basename "$VIRTUAL_ENV")
        # Removed the trailing space so it hugs the git branch tightly
        set venv_prompt (set_color cyan)"[$venv_name]"(set_color normal)
    end

    # Detect Rust project by checking for Cargo context
    set -l rust_prompt ""
    if type -q cargo; and cargo locate-project --quiet >/dev/null 2>&1
        set rust_prompt (set_color ffa500)"(Rust)"(set_color normal)
    end

    if functions -q fish_is_root_user; and fish_is_root_user
        printf '%s@%s %s%s%s# ' $USER (prompt_hostname) (set -q fish_color_cwd_root
                                                          and set_color $fish_color_cwd_root
                                                          or set_color $fish_color_cwd) \
            (prompt_pwd) (set_color --reset)
    else
        set -l status_color (set_color $fish_color_status)
        set -l statusb_color (set_color --bold $fish_color_status)
        set -l pipestatus_string (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

        # Capture git prompt state to manage dynamic spacing
        set -l vcs_string (fish_vcs_prompt)

        # If not in a git repo but venv/rust is active, ensure there is a space after the path
        if test -z "$vcs_string"; and test -n "$venv_prompt$rust_prompt"
            set vcs_string " "
        end

        # Print layout with adjusted variables pushed together
        printf '[%s] %b%s%b@%b%s %b%s%s%b%s%s%s%s\n> ' \
            (date "+%H:%M:%S") \
            (set_color --bold red) $USER (set_color normal) (set_color --bold red) (prompt_hostname) \
            (set_color $fish_color_cwd) $PWD $pipestatus_string \
            (set_color --reset) $vcs_string $venv_prompt $rust_prompt
    end
end

# OpenClaw Completion
test -f "/home/vito/.openclaw/completions/openclaw.fish"; and source "/home/vito/.openclaw/completions/openclaw.fish"

# Disable XON/XOFF so Ctrl+S works in Neovim
stty -ixon
