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
| **TOOLS** | CapsLock (toggle) | Dev tools (tmux, nvim, lf) |
| **FZF** | LeftControl (oneshot) or Tab from TOOLS | FZF/RG/Zoxide utilities |

### Quick Reference - All Keybindings

| Layer | Trigger | Key | Purpose/Action |
|-------|---------|-----|----------------|
| **BASE** | Default | A/S/D/F (hold) | Meta/Alt/Shift/Ctrl (left hand) |
| **BASE** | Default | J/K/L/; (hold) | Ctrl/Shift/Alt/Meta (right hand) |
| **BASE** | Default | LeftShift | Escape |
| **BASE** | Default | RightShift | Backspace |
| **BASE** | Default | RightAlt | Toggle CODE layer |
| **BASE** | Default | RightControl | Toggle/oneshot POWER layer |
| **BASE** | Default | Menu/Compose | Toggle NUM layer |
| **BASE** | Default | CapsLock | Toggle TOOLS layer |
| **BASE** | Default | LeftControl | Oneshot FZF layer |
| **CODE** | RightAlt | 1-5 | F5,F9-F12 (debugging) |
| **CODE** | RightAlt | G | Go to Definition |
| **CODE** | RightAlt | A/E | Home/End |
| **CODE** | RightAlt | S/D | PageUp/PageDown |
| **CODE** | RightAlt | 6-9 | Command Palette, Quick Open, Search, Sidebar |
| **CODE** | RightAlt | B/T/W/N/P | Tmux prefix/new/close/next/prev |
| **CODE** | RightAlt | H/J/K/L | Window focus left/down/up/right |
| **CODE** | RightAlt | ;/Space | Escape |
| **POWER** | RightControl | 1-0 | Workspace 1-10 |
| **POWER** | RightControl | H/J/K/L | Focus window |
| **POWER** | RightControl | Z/X/C/V | Move window |
| **POWER** | RightControl | Q/F/N | Kill/Fullscreen/Float |
| **POWER** | RightControl | E/R/W/M | Launch file manager/editor/browser/Discord |
| **POWER** | RightControl | S/P | Screenshot |
| **NUM** | Menu | U/I/O | 7/8/9 |
| **NUM** | Menu | J/K/L | 4/5/6 |
| **NUM** | Menu | M/,/Space | 1/2/0 |
| **NUM** | Menu | ;/P/Y/H | + - * / |
| **TOOLS** | CapsLock | T/N/F/O/D | Terminal/Neovim/lf/OpenCode/Droid |
| **TOOLS** | CapsLock | 1-0 | Tmux windows 1-10 |
| **TOOLS** | CapsLock | B/H/J/K/L | Tmux prefix/pane navigation |
| **TOOLS** | CapsLock | C/W/N/P | Tmux new window/list/next/prev |
| **TOOLS** | CapsLock | V/G | Tmux split vertical/horizontal |
| **TOOLS** | CapsLock | Tab | Toggle FZF layer |
| **FZF** | LeftControl/Tab | J | fzcd - zoxide jump |
| **FZF** | LeftControl/Tab | F | fzfind - file search |
| **FZF** | LeftControl/Tab | G | fzfind -rg - content search |
| **FZF** | LeftControl/Tab | B | fzgit branch |
| **FZF** | LeftControl/Tab | L | fzgit log |
| **FZF** | LeftControl/Tab | S | fzgit status |
| **FZF** | LeftControl/Tab | Shift+S | fzgit stash |
| **FZF** | LeftControl/Tab | C | fzgit commit |
| **FZF** | LeftControl/Tab | W | fzgit worktree |
| **FZF** | LeftControl/Tab | H | fzhist - command history |

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

#### Symbol Overloading (Number Row & Bottom Row)

Using `overload()` with a dedicated `[symbols]` layer: tap for the base key, hold for the shifted symbol.

**Number Row** - tap for number, hold for shifted symbol:

| Key | \` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 | - | = |
|-----|-----|---|---|---|---|---|---|---|---|---|---|---|---|
| Tap | \` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 | - | = |
| Hold | ~ | ! | @ | # | $ | % | ^ | & | * | ( | ) | _ | + |

**Bottom Row & Apostrophe** - tap for symbol, hold for shifted symbol:

| Key | , | . | / | ' |
|-----|---|---|---|---|
| Tap | , | . | / | ' |
| Hold | < | > | ? | : |

**Implementation:** Uses `overload(symbols, key)` in `[main]` layer with shifted symbols defined in `[symbols]` layer.

---

## Layer Details

### BASE Layer

Default typing layer with:
- Home row modifiers (via `overloadt2`, 180ms timeout)
- Symbol overloading using `overload()` with `[symbols]` layer
- Shift key overrides (LeftShift=Esc, RightShift=Backspace)
- Layer toggles

**Symbol Overload Mappings:**
Using `overload(symbols, key)` syntax - tap for base key, hold for shifted symbol:
- Number row: `1 = overload(symbols, 1)` → tap=1, hold=!
- Bottom row: `comma = overload(symbols, comma)` → tap=,, hold=<
- Apostrophe: `apostrophe = overload(symbols, apostrophe)` → tap=', hold=:

The `[symbols]` layer defines the shifted outputs: `1 = S-1` (!), `comma = S-comma` (<), etc.

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

### TOOLS Layer (Development Tools)

**Trigger:** CapsLock (toggle)

**Launchers:**
| Key | Action |
|-----|--------|
| T | Launch Terminal (with tmux) |
| N | Launch Neovim |
| F | Launch lf file manager |
| O | Launch OpenCode |
| D | Launch Droid |

**TMUX Controls:**
| Key | Action |
|-----|--------|
| B | Send prefix (C-b) |
| H/J/K/L | Pane navigation |
| C | New window |
| W | Window list |
| N/P | Next/Previous window |
| V/G | Split vertical/horizontal |

**Exit:** Press `Esc` or `CapsLock` again

### FZF Layer (RG/FD/Zoxide Utilities)

**Trigger:** LeftControl (oneshot hold) or Tab from TOOLS layer

**Zoxide Directory Jumping:**
| Key | Script | Action |
|-----|--------|--------|
| J | `fzcd` | Interactive zoxide jump with preview |
| Z | - | Zoxide jump fallback |

**File Search (FD + RG):**
| Key | Script | Action |
|-----|--------|--------|
| F | `fzfind` | File search with fd + preview |
| G | `fzfind -r` | Content search with ripgrep |
| R | - | Raw rg search mode |

**Git Operations:**
| Key | Script | Action |
|-----|--------|--------|
| B | `fzgit branch` | Branch switch/merge/delete |
| L | `fzgit log` | Browse commit history |
| S | `fzgit status` | Interactive staging |
| Shift+S | `fzgit stash` | Stash management |
| C | `fzgit commit` | Build commit interactively |
| W | `fzgit worktree` | Worktree management |

**History & Shell:**
| Key | Script | Action |
|-----|--------|--------|
| H | `fzhist` | Search command history |
| M | - | Man pages with fzf |

**Exit:** Press `Esc`, release LeftControl, or press `Tab` again

---

## FZF Utility Scripts

Four powerful CLI utilities using `fzf`, `rg`, `fd`, and `zoxide`:

### fzcd - Directory Jumping
```bash
fzcd [initial-query]     # Interactive zoxide jump
```
- **Ctrl-D:** Print path without cd
- **Ctrl-R:** Refresh zoxide database
- **Ctrl-F:** Switch to fd search mode
- Preview shows directory contents

### fzfind - File Search
```bash
fzfind [directory] [query]      # Find files with preview
fzfind -r <pattern>             # Search content with rg
```
- **Ctrl-O:** Open in $EDITOR
- **Ctrl-Y:** Copy path to clipboard
- **Ctrl-D:** cd to file's directory
- **Ctrl-R:** Switch to content search
- Uses `bat` for syntax-highlighted preview if available

### fzgit - Git Operations
```bash
fzgit log        # Browse commits with diff preview
fzgit branch     # Switch, merge, rebase, delete branches
fzgit stash      # Pop, apply, drop stashes
fzgit status     # Interactive staging/unstaging
fzgit commit     # Build commit with file selection
fzgit worktree   # Manage git worktrees
fzgit remote     # Checkout remote branches
```

### fzhist - Command History
```bash
fzhist [query]    # Search shell history
```
- **Ctrl-E:** Edit command before execution
- **Ctrl-Y:** Copy to clipboard
- **Ctrl-R:** Show raw history
- **Alt-Enter:** Print without executing

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
| `overloadt2(layer, key, timeout)` | Like overload but with explicit timeout (used for home row mods) |
| `timeout(hold_action, timeout, tap_action)` | Hold for timeout ms = hold_action, tap = tap_action (used for symbols) |
| `toggle(layer)` | Toggle layer on/off |
| `oneshot(layer)` | Active for next key only |

### Timing Parameters

- **Global overload timeout:** 200ms (`overload_tap_timeout`)
- **Home row mods:** 180ms (per-key via `overloadt2`)
- **Symbol timeout:** 100ms (number row, bottom row, apostrophe via `timeout()`)

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
9. **Replaced invalid `timeout()` with `overload()` for symbols** - Uses `[symbols]` layer for shifted outputs
10. **Added `[symbols]` layer** - Defines shifted symbols for number row and bottom row
11. **Added bottom row symbols** - comma, dot, slash with `overload(symbols, key)`
12. **Added apostrophe mapping** - `overload(symbols, apostrophe)` → tap `'`, hold `:`

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
