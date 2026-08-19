#!/usr/bin/env bash
set -euo pipefail

# === Hyprland Environment Bootstrap ===
# Replicates my full Hyprland setup on a fresh Arch machine
# Run from the repo root (~/.config/hypr/ or cloned copy)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}WARN:${NC} $*"; }
err() { echo -e "${RED}ERROR:${NC} $*"; }

# === Preflight ===
if ! command -v pacman &>/dev/null; then
  err "pacman not found. This script is for Arch-based distros only."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Warn if cloned inside config dir (ugly but functional)
if [[ "$SCRIPT_DIR" == "$HOME/.config/hypr"* ]]; then
  warn "repo cloned inside ~/.config/hypr/"
  echo "  Consider moving it: mv $SCRIPT_DIR ~/"
fi

# === Package Installation ===
log "Installing packages from pkglist.txt..."
if [[ -f pkglist.txt ]]; then
  grep -v '^#' pkglist.txt | grep -v '^$' | sudo pacman -S --needed --noconfirm -
else
  warn "pkglist.txt not found — skipping package install."
fi

# === Install AUR packages directly from source (no helper needed) ===
if [[ -f aurlist.txt ]] && grep -q '^[^#]' aurlist.txt 2>/dev/null; then
  log "Installing AUR packages from source..."
  sudo pacman -S --needed --noconfirm base-devel git
  AUR_TMP="$(mktemp -d)"
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    if pacman -Q "$pkg" &>/dev/null; then
      log "  $pkg already installed — skipping"
      continue
    fi
    log "  Building $pkg..."
    git clone "https://aur.archlinux.org/$pkg.git" "$AUR_TMP/$pkg"
    (cd "$AUR_TMP/$pkg" && makepkg -si --noconfirm --skippgpcheck)
  done <aurlist.txt
  rm -rf "$AUR_TMP"
fi

# === Stow Config Files ===
if ! command -v stow &>/dev/null; then
  log "Installing stow..."
  sudo pacman -S --needed --noconfirm stow
fi

log "Stowing configuration files..."
STOW_PKGS=(hypr waybar rofi kitty wezterm fastfetch fish swaync swayosd slurp uwsm gtk qt xsettingsd icons nvidia wallpapers zsh)
for pkg in "${STOW_PKGS[@]}"; do
  if [[ -d "$pkg" ]]; then
    log "  Stowing: $pkg"
    # Remove real files at target that would conflict (keep existing symlinks)
    find "$pkg" -type f -printf '%P\n' | while read -r f; do
      target="$HOME/$f"
      if [[ -f "$target" && ! -L "$target" ]]; then
        rm -f "$target"
      fi
    done
    stow -t "$HOME" -R -v "$pkg"
  fi
done

# === Enable User Services ======
log "Enabling user-level systemd services..."
systemctl --user enable --now pipewire.socket 2>/dev/null || true
systemctl --user enable --now wireplumber.service 2>/dev/null || true

# Set fish as default shell
if command -v fish &>/dev/null && [[ "$SHELL" != *fish ]]; then
  log "Setting fish as default shell..."
  chsh -s /usr/bin/fish
fi

# Verify Deployment
CHECK_FILES=(
  "$HOME/.config/hypr/hyprland.lua"
  "$HOME/.config/waybar/config.jsonc"
  "$HOME/.config/kitty/kitty.conf"
  "$HOME/.config/wezterm/wezterm.lua"
  "$HOME/.config/fish/config.fish"
  "$HOME/.config/swaync/config.json"
  "$HOME/.config/rofi/config.rasi"
)
FAILED=0
for f in "${CHECK_FILES[@]}"; do
  if [[ -L "$f" ]] || [[ -f "$f" ]]; then
    echo -e "  ${GREEN}✓${NC} $f"
  else
    echo -e "  ${RED}✗${NC} $f"
    FAILED=1
  fi
done

# === Post-Install ===
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
if [[ $FAILED -eq 1 ]]; then
  echo -e "${RED}  Some configs failed to deploy — check errors above${NC}"
else
  echo -e "${GREEN}  All configs deployed${NC}"
fi
echo ""

# Detect session type for start instructions
if command -v uwsm &>/dev/null; then
  echo -e "Start Hyprland:"
  echo -e "  ${YELLOW}uwsm start hyprland${NC}"
elif command -v hyprland &>/dev/null; then
  echo -e "Start Hyprland:"
  echo -e "  ${YELLOW}Hyprland${NC}"
fi

echo ""
echo -e "Wallpaper: edit ${YELLOW}~/.config/hypr/startup.lua${NC} if path differs"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
