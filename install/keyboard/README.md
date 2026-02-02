# Keyd Configuration for Keychron K2 V2

System-level keyboard remapping daemon configuration for the Keychron K2 V2 (84-key) keyboard on Arch Linux with Hyprland.

## Overview

This configuration provides an intent-based input system with 4+ distinct layers optimized for:
- Modal editing (Neovim/Vim)
- Window management (Hyprland)
- IDE usage (VSCode/VSCodium)
- Numeric data entry
- System control

### Core Philosophy

**"Intent-based input"** - separate typing, coding, window management, and numeric entry into distinct physical contexts, minimizing finger strain from prolonged key holds.

---

## Features

### Layer System

| Layer | Trigger | Purpose |
|-------|---------|---------|
| **BASE** | Default | Typing with home-row mods |
| **CODE** | RightAlt (toggle) | IDE/Neovim commands |
| **POWER** | RightControl (oneshot/toggle) | Hyprland WM, applications |
| **NUM** | Menu/Compose (toggle) | Data entry, calculator |

### Key Remappings

#### Shift Key Overrides
- **LeftShift** → **Escape** (Vim mode exit, left pinky)
- **RightShift** → **Backspace** (deletion, right pinky)

#### Home Row Modifiers
Using `overloadt2` for tap/hold detection (180ms timeout):

**Left Hand:**
- `A` = Meta (tap = a)
- `S` = Alt (tap = s)
- `D` = Shift (tap = d)
- `F` = Ctrl (tap = f)

**Right Hand:**
- `J` = Ctrl (tap = j)
- `K` = Shift (tap = k)
- `L` = Alt (tap = l)
- `;` = Meta (tap = semicolon)

#### Symbol Overloading
Number row provides shifted symbols on hold:
- Tap: `1 2 3 4 5 6 7 8 9 0 - =`
- Hold: `! @ # $ % ^ & * ( ) _ +`

---

## Layer Details

### BASE Layer

Default typing layer with:
- Home row modifiers (via `overloadt2`)
- Symbol overloading on number row
- Shift key overrides
- Layer toggles

**Layer Toggle Keys:**
```
RightAlt       = toggle(CODE layer)
RightControl   = oneshot(POWER layer)
Compose/Menu   = toggle(NUM layer)
```

### CODE Layer (Development)

**Trigger:** RightAlt (toggle on/off)

**F-Keys (Debugging):**
| Key | Action |
|-----|--------|
| 1 | F5 (Run) |
| 2 | F9 (Breakpoint) |
| 3 | F10 (Step Over) |
| 4 | F11 (Step Into) |
| 5 | F12 (Step Out) |

**Navigation:**
| Key | Action |
|-----|--------|
| G | Meta+Ctrl+G (Go to Definition) |
| A | Home (Start of Line) |
| E | End (End of Line) |
| S | PageUp |
| D | PageDown |

**IDE Commands:**
| Key | Action |
|-----|--------|
| 6 | Meta+Shift+P (Command Palette) |
| 7 | Meta+P (Quick Open) |
| 8 | Meta+Shift+F (Global Search) |
| 9 | Meta+B (Toggle Sidebar) |

**LSP Features:**
| Key | Action |
|-----|--------|
| I | Meta+I (Trigger Suggestion) |
| O | Meta+Shift+O (Go to Symbol) |
| . | Meta+. (Quick Fix) |

**Shortcuts:**
| Key | Action |
|-----|--------|
| ' | Meta+' (Format Document) |
| [ | Meta+[ (Go to Bracket) |
| ] | Meta+] (Go to Bracket Close) |
| \ | Meta+F (Find in File) |

**Terminal Multiplexer (tmux):**
| Key | Action |
|-----|--------|
| B | Ctrl+B (tmux prefix) |
| T | Ctrl+T (New pane/window) |
| W | Ctrl+W (Close pane) |
| N | Ctrl+N (Next window) |
| P | Ctrl+P (Previous window) |

**Search & Edit:**
| Key | Action |
|-----|--------|
| X | Meta+X (Cut) |
| R | Meta+R (Rename) |
| F | Meta+F (Find) |
| H | Meta+Shift+F (Replace) |
| U | Meta+U |

**Vim-Specific:**
| Key | Action |
|-----|--------|
| ; | Escape |
| C | Meta+Shift+D (Delete line) |
| V | Meta+Shift+V (Paste) |
| Z | Meta+Z (Undo) |
| Space | Escape |

**Window Management (Hyprland):**
| Key | Action |
|-----|--------|
| H | Meta+H (Focus left) |
| J | Meta+J (Focus down) |
| K | Meta+K (Focus up) |
| L | Meta+L (Focus right) |

**Workspace Switching:**
| Key | Action |
|-----|--------|
| Y | Shift+1 (Workspace 1) |
| U | Shift+2 (Workspace 2) |

**Exit:** Press `Esc` or `RightAlt` again

### POWER Layer (System/Window Management)

**Trigger:** RightControl (oneshot = single key, toggle = double-tap)

**Philosophy:** "God Mode" - every key assumes implicit Super/Meta prefix

**Workspace Switching:**
| Key | Action |
|-----|--------|
| 1-0 | Meta+1 through Meta+0 |

**Window Focus:**
| Key | Action |
|-----|--------|
| H | Meta+H (Focus left) |
| J | Meta+J (Focus down) |
| K | Meta+K (Focus up) |
| L | Meta+L (Focus right) |

**Window Move (with Shift):**
| Key | Action |
|-----|--------|
| Z | Shift+Meta+H (Move left) |
| X | Shift+Meta+J (Move down) |
| C | Shift+Meta+K (Move up) |
| V | Shift+Meta+L (Move right) |

**Window Lifecycle:**
| Key | Action |
|-----|--------|
| Q | Meta+Q (Kill window) |
| F | Meta+F (Fullscreen toggle) |
| N | Meta+Shift+Space (Float toggle) |

**Window Manipulation:**
| Key | Action |
|-----|--------|
| T | Meta+T (Make tiling) |
| G | Meta+G (Toggle tabbed) |
| B | Meta+B (Make floating tabbed) |
| D | Meta+D (Toggle opacity) |

**Application Launchers:**
| Key | Action |
|-----|--------|
| E | Meta+E (Launch file manager) |
| R | Meta+R (Launch editor) |
| W | Meta+W (Launch browser) |
| M | Meta+M (Launch Discord/Slack) |
| U | Meta+U (Launch notes) |
| O | Meta+O (System settings) |
| I | Meta+I (Calculator/emoji) |
| A | Meta+A (Application launcher) |

**Screenshot Utilities:**
| Key | Action |
|-----|--------|
| S | Meta+Ctrl+S (Screenshot mode) |
| P | Meta+Shift+P (Screenshot window) |

**Workspace Management:**
| Key | Action |
|-----|--------|
| = | Meta+= (New workspace) |
| - | Meta+- |
| , | Meta+, (Move workspace left) |
| . | Meta+. (Move workspace right) |

**Exit:** Press `Esc` or `RightControl` again

### NUM Layer (Numeric/T9)

**Trigger:** Menu/Compose key (toggle)

T9 phone-style numpad on letter keys:
```
U I O  →  7 8 9
J K L  →  4 5 6
M ,    →  1 2
Space  →  0
```

**Operators:**
| Key | Action |
|-----|--------|
| ; | KPPlus (+) |
| P | KPMinus (-) |
| Y | KPAsterisk (*) |
| H | KPSlash (/) |
| / | KPEnter |

**Exit:** Press `Esc` or `Menu/Compose` again

---

## Installation

### Prerequisites

- Arch Linux system
- Keychron K2 V2 keyboard (84-key)
- sudo privileges
- Hyprland (recommended for POWER layer)

### Quick Install

1. Clone or navigate to the repository:
```bash
cd /home/debasmitr/workspace/dotFileV2/install/keyboard
```

2. Run the installation script:
```bash
chmod +x install.sh
./install.sh
```

3. The script will:
   - Install keyd if not present (`sudo pacman -S keyd`)
   - Backup existing configurations
   - Detect your keyboard device
   - Install configuration files to `/etc/keyd/` and `~/.config/keyd/`
   - Enable and start keyd systemd service

### Manual Install

1. Install keyd:
```bash
sudo pacman -S keyd
```

2. Copy configurations:
```bash
sudo mkdir -p /etc/keyd
sudo cp keyd/default.conf /etc/keyd/default.conf

mkdir -p ~/.config/keyd
cp keyd/app.conf ~/.config/keyd/app.conf
```

3. Detect your keyboard (optional):
```bash
ls -la /dev/input/by-path/ | grep -i "event-kbd"
```

4. Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable keyd
sudo systemctl start keyd
```

---

## Configuration Files

### System Configuration: `/etc/keyd/default.conf`

Main configuration containing:
- `[ids]` section with `*` (matches all keyboards)
- `[global]` with `overload_tap_timeout = 200`
- `[main]` base layer with home row mods
- Layer definitions: `[symbols]`, `[code]`, `[power]`, `[num]`
- Modifier layers for home row mods: `[meta_a:M]`, `[alt_s:A]`, etc.

### User Configuration: `~/.config/keyd/app.conf`

Application-specific remappings for terminal emulators:
- Alacritty, Kitty, Foot, GNOME Terminal
- Ctrl+C remapping (Copy vs SIGINT)

---

## Panic Key

**IMPORTANT:** If keyd locks your input, press simultaneously:
```
Backspace + Escape + Enter
```

This immediately terminates the keyd daemon.

**Test this combination after installation to ensure it works!**

---

## Usage

### Layer Switching

```bash
# Enter CODE mode (toggle on/off)
Press RightAlt

# Enter POWER mode (oneshot - single key then auto-exit)
Press RightControl

# Enter POWER mode (toggle - stay in layer)
Press RightControl twice quickly

# Enter NUM mode (toggle)
Press Menu/Compose key

# Exit any layer
Press Escape or the layer trigger key again
```

### Testing & Monitoring

```bash
# Monitor keyboard events in real-time
sudo keyd monitor

# Check service status
sudo systemctl status keyd

# View logs
sudo journalctl -u keyd --no-pager

# Validate configuration
sudo keyd check /etc/keyd/default.conf

# Reload configuration without restart
sudo keyd reload
```

### Customization

Edit the configuration and restart:
```bash
sudo vim /etc/keyd/default.conf
sudo systemctl restart keyd
# OR
sudo keyd reload
```

---

## Troubleshooting

### Configuration Validation Failed

Check syntax:
```bash
sudo keyd check /etc/keyd/default.conf
```

Common issues:
- Missing `[ids]` section
- Invalid key names (use `keyd list-keys` to see valid names)
- Invalid action syntax
- Layer names with invalid characters

### Keyboard Not Detected

1. List available devices:
```bash
ls -la /dev/input/by-path/ | grep -i "event-kbd"
```

2. For specific keyboard targeting, add to `[ids]` section:
```ini
[ids]
-013d:0002  # Exclude device
*           # Match all others
```

### Service Not Starting

Check logs:
```bash
sudo journalctl -u keyd --no-pager
```

Common issues:
- Syntax errors in configuration
- Missing permissions on `/etc/keyd/`
- Conflicting with other input remappers (disable them)

### Home Row Mods Not Working

The configuration uses `overloadt2()` with 180ms timeout. If taps feel delayed:
- Decrease timeout in `[global]` section
- Or decrease the third parameter in `overloadt2(layer, key, timeout)`

### Layer Toggle Not Working

Verify the trigger key isn't being intercepted by your desktop environment. Check with:
```bash
sudo keyd monitor
```

---

## Technical Details

### Keyd Actions Used

| Action | Description |
|--------|-------------|
| `overload(layer, key)` | Tap = key, Hold = layer |
| `overloadt2(layer, key, timeout)` | Like overload but with explicit timeout |
| `toggle(layer)` | Toggle layer on/off |
| `oneshot(layer)` | Active for next key only |
| `lettermod(mod, key, tap_ms, hold_ms)` | Not used (not available in keyd) |

### Timing Parameters

- **Global overload timeout:** 200ms (`overload_tap_timeout`)
- **Home row mods:** 180ms (per-key via `overloadt2`)

### Modifier Notation

| Notation | Meaning |
|----------|---------|
| `M-` | Meta/Super |
| `C-` | Control |
| `S-` | Shift |
| `A-` | Alt |
| `M-S-` | Meta+Shift |
| `M-C-` | Meta+Control |
| `S-M-` | Shift+Meta |

---

## Migration from Kanata

| Kanata | keyd Equivalent |
|--------|-----------------|
| `(deflayer name)` | `[name]` |
| `layer-toggle name` | `toggle(name)` |
| `tap-hold 200 200 key mod` | `overloadt2(modlayer, key, 200)` |
| `@alias` | Direct assignment |
| `(defalias)` | Not needed |

---

## Key Changes Made (Fixes)

### Configuration Fixes

1. **Added `[ids]` section** - Required by keyd v2.6.0
2. **Added `[global]` section** - Set `overload_tap_timeout = 200`
3. **Replaced `lettermod()` with `overloadt2()`** - `lettermod` is not a valid keyd action
4. **Fixed invalid key names:**
   - `quote` → `apostrophe`
   - `leftbracket` → `leftbrace`
   - `rightbracket` → `rightbrace`
5. **Fixed `overload()` syntax** - Takes 2 args (layer, tap-key), not 3
6. **Removed invalid key codes** - `b1`, `s1`, `pwr`, etc. are not valid keyd names
7. **Removed non-existent keypad codes** - `kpequal`, `kpmemoryadd`, etc.
8. **Added modifier layers** - `[meta_a:M]`, `[alt_s:A]`, etc. for home row mods

### Install Script Fixes

1. **Fixed validation command** - Changed `keyd -c file --validate` to `keyd check file`

---

## Useful Commands

```bash
# List all valid key names
keyd list-keys

# Monitor keyboard input
sudo keyd monitor

# Check configuration
sudo keyd check /etc/keyd/default.conf

# Reload configuration
sudo keyd reload

# Service management
sudo systemctl status keyd
sudo systemctl restart keyd
sudo systemctl stop keyd
sudo systemctl disable keyd
```

---

## Credits

Configuration originally based on Product Requirements Document (PRD) for Keyd Keyboard Remapping Architecture, adapted and fixed for keyd v2.6.0 compatibility.

## License

This configuration is provided as-is for personal use.
