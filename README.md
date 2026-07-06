# my-hyprland-configs

Personal Hyprland environment configs alongside all of my basic environment apps

## Quick Replicate

```bash
git clone https://github.com/VictorFilizola/my-hyprland-configs.git
cd my-hyprland-configs
./bootstrap.sh
```

Installs all packages, stows configs, enables services. Reboot and Hyprland is ready.

## OBS - Activate Websocket for Waybar recording Status

- Open OBS
- Go to "Tools"
- Click "Websocket Server Settings"
- Check the tick-box at "Enable Websocket server"

The script will automatically auth OBS to use its recording status with it's uptime

## SwayOSD — systemd backend (required)

Volume/brightness OSD uses SwayOSD. It has two parts:

- `swayosd-libinput-backend` — **system** service (root), reads input devices
- `swayosd-server` — **user** process, shows OSD + changes volume

The systemd backend must be **enabled** or OSD + volume keys silently fail:

```bash
sudo systemctl enable --now swayosd-libinput-backend.service
```

Verify:

```bash
systemctl is-active swayosd-libinput-backend.service  # → active
```

No OSD without this. Volume keys do nothing without this.

## Files

| File              | Purpose                                                                                         |
| ----------------- | ----------------------------------------------------------------------------------------------- |
| `hyprland.lua`    | Entry point — requires all modules in order                                                     |
| `colors.lua`      | Centralized color palette (accent, surface, muted, text, shadow)                                |
| `env.lua`         | Environment variables (cursor size, Qt theme)                                                   |
| `monitors.lua`    | Display configuration (auto-detect preferred)                                                   |
| `input.lua`       | Keyboard layout (`us-intl`), mouse/touchpad, per-device sensitivity, 3-finger workspace gesture |
| `appearance.lua`  | Gaps, borders, rounding, opacity, shadows, blur (off), dwindle/master presets                   |
| `animations.lua`  | Bezier curves, spring presets, window/layer/workspace animations                                |
| `programs.lua`    | User-facing app shortcuts (terminal, file manager, launcher, browser)                           |
| `keybinds.lua`    | All keybinds — window management, media keys, screenshots, workspace nav                        |
| `startup.lua`     | Daemons launched at start (Waybar, SwayOSD, SwayNC, hypridle, swaybg, nm-applet, blueman)       |
| `windowrules.lua` | Window rules — suppress maximize, fix XWayland drags, float hyprland-run                        |

## Keybinds

Mod key: `SUPER` (Windows key)

| Keys                            | Action                                           |
| ------------------------------- | ------------------------------------------------ |
| `SUPER + Return`                | Terminal (wezterm)                               |
| `SUPER + Q`                     | Close window                                     |
| `SUPER + E`                     | File manager (nemo)                              |
| `SUPER + Space`                 | App launcher (rofi)                              |
| `SUPER + H`                     | System settings (gnome-control-center)           |
| `SUPER + Escape`                | Lock screen (hyprlock)                           |
| `SUPER + G`                     | Toggle float + center (50% size)                 |
| `SUPER + V`                     | Audio mixer (pavucontrol)                        |
| `SUPER + P`                     | Toggle pseudo-tile                               |
| `SUPER + J`                     | Toggle split direction                           |
| `SUPER + Y/U/I/O/P`             | Switch workspace 1-5                             |
| `SUPER + Shift + Y/U/I/O/P`     | Move window to workspace 1-5                     |
| `SUPER + left/right`            | Previous/next workspace                          |
| `SUPER + Shift + arrows`        | Move focus                                       |
| `SUPER + drag (LMB)`            | Move window                                      |
| `SUPER + drag (RMB)`            | Resize window                                    |
| `Print`                         | Screenshot region → annotate (hyprshot + swappy) |
| `SUPER + Shift + S`             | Screenshot region → clipboard                    |
| `XF86AudioRaiseVolume`          | Volume up + OSD                                  |
| `XF86AudioLowerVolume`          | Volume down + OSD                                |
| `XF86AudioMute`                 | Mute toggle + OSD                                |
| `XF86AudioMicMute`              | Mic mute toggle                                  |
| `XF86MonBrightnessUp`           | Brightness up + OSD                              |
| `XF86MonBrightnessDown`         | Brightness down + OSD                            |
| `XF86AudioNext/Play/Pause/Prev` | Media control (playerctl)                        |

## Dependencies

### Core

| Package    | Purpose            |
| ---------- | ------------------ |
| `hyprland` | Wayland compositor |

### Daemons (auto-started in startup.lua)

| Package                                | Purpose                                                 |
| -------------------------------------- | ------------------------------------------------------- |
| `waybar`                               | Status bar                                              |
| `swayosd`                              | Volume/brightness OSD (swayosd-client + swayosd-server) |
| `swaync`                               | Notification daemon                                     |
| `hypridle`                             | Idle management (auto-lock, suspend)                    |
| `swaybg`                               | Wallpaper setter                                        |
| `network-manager-applet` (`nm-applet`) | WiFi network tray applet                                |
| `blueman` (`blueman-applet`)           | Bluetooth tray applet + manager                         |

### Applications

| Package | Purpose           |
| ------- | ----------------- |
| `kitty`  | Terminal emulator |
| `wezterm` | Terminal emulator |
| `nemo`  | File manager      |
| `rofi`  | App launcher      |
| `brave` | Web browser       |

### Utilities

| Package       | Purpose                                         |
| ------------- | ----------------------------------------------- |
| `hyprshot`    | Screenshot tool                                 |
| `swappy`      | Screenshot annotation                           |
| `hyprlock`    | Screen locker                                   |
| `wlogout`     | Powermenu (logout/reboot/shutdown/suspend/lock) |
| `wireplumber` | Audio routing (provides `wpctl`)                |
| `playerctl`   | Media player control                            |

### Install (Arch)

**Automated:**

```bash
./bootstrap.sh
```

**Manual:**

```bash
sudo pacman -S --needed - < pkglist.txt
cd stow && for d in */; do stow -t "$HOME" "$d"; done
```

## Stow Packages

Non-Hyprland configs managed via GNU Stow under `stow/`:

| Package      | Contents                                                |
| ------------ | ------------------------------------------------------- |
| `hypr`       | Hyprland compositor — Lua modules + hypridle + hyprlock |
| `waybar`     | Status bar config + scripts (clock, cpu, media, window) |
| `rofi`       | App launcher + squared-material-red theme               |
| `kitty`      | Terminal emulator + VSCode_Dark theme                   |
| `wezterm`    | Terminal emulator (GPU-accelerated) + red-accent theme  |
| `fastfetch`  | System info (builtin distro logo, optional custom art)  |
| `fish`       | Shell config, functions, prompt, color scheme           |
| `swaync`     | Notification daemon + control center                    |
| `swayosd`    | Volume/brightness OSD                                   |
| `slurp`      | Screenshot region selector (red border)                 |
| `uwsm`       | NVIDIA env vars for Wayland session                     |
| `gtk`        | GTK2/3/4 theme (Breeze-Dark)                            |
| `qt`         | Qt5/Qt6 theme (CosmicDark)                              |
| `xsettingsd` | Theme sync daemon                                       |
| `icons`      | Sweet-cursors cursor theme                              |
| `nvidia`     | GPU power mode settings                                 |
| `wallpapers` | Wallpaper images                                        |

## Customization

- Terminal: edit `programs.lua` → `terminal` (default: wezterm)
- File manager: edit `programs.lua` → `fileManager`
- Launcher: edit `programs.lua` → `menu`
- Browser: edit `programs.lua` → `browser`
- Wallpaper path: edit `startup.lua` → `swaybg` command
- Gaps, borders, opacity: edit `appearance.lua`
- Keybinds: edit `keybinds.lua`
