# Productivity Guide for Keyd Configuration

This document provides a practical guide to using the keyd configuration for maximum productivity on the Keychron K2 V2 keyboard.

## Quick Reference

### Layer Triggers

| Layer | Trigger | Mode | Exit |
|-------|---------|------|------|
| CODE | RightAlt | Toggle | RightAlt or Esc |
| POWER | RightControl | Oneshot/Toggle | Esc or timeout |
| NUM | Menu/Compose | Toggle | Menu or Esc |

### Home Row Mods

| Key | Modifier | Tap Output |
|-----|----------|------------|
| A | Meta | a |
| S | Alt | s |
| D | Shift | d |
| F | Ctrl | f |
| J | Ctrl | j |
| K | Shift | k |
| L | Alt | l |
| ; | Meta | semicolon |

**Usage:** Quick tap for character, hold for modifier.

### Shift Overrides

- **LeftShift** = Escape (tap for Esc)
- **RightShift** = Backspace (tap for Backspace)

---

## Workflow Examples

### Developer Workflow

**Switching to coding mode:**
1. Press `RightAlt` → Enter CODE layer
2. Use single-key shortcuts for IDE commands
3. Press `RightAlt` again → Back to BASE

**Common CODE layer operations:**
```
Go to Definition:      G
Command Palette:       6
Quick Open:            7
Global Search:         8
Toggle Sidebar:        9
Format Document:       '
Go to Bracket:         [ or ]
Find in File:          \
Cut:                   X
Rename:                R
Replace:               H
```

**Window management while coding:**
1. Tap `RightControl` (oneshot) → Next key gets Super prefix
2. Press `H/J/K/L` → Focus window in direction
3. Or press `1-0` → Switch workspace

**Terminal work with tmux:**
1. In CODE layer: Press `B` → Ctrl+B (tmux prefix)
2. Then: `T` for new window, `N/P` for navigation

### System Administrator Workflow

**Power user operations:**
1. Double-tap `RightControl` → Enter POWER layer (toggle mode)
2. Access all system shortcuts with single keys

**Launching applications:**
```
File Manager:    E
Editor:          R
Browser:         W
Discord/Slack:   M
Notes:           U
Settings:        O
Launcher:        A
```

**Window management:**
```
Focus:           H J K L
Move:            Z X C V
Kill:            Q
Fullscreen:      F
Float Toggle:    N
```

**Screenshot workflow:**
```
Screenshot Mode:     S (Meta+Ctrl+S)
Screenshot Window:   P (Meta+Shift+P)
```

### Numeric Data Entry

**Calculator/numpad mode:**
1. Press `Menu/Compose` → Enter NUM layer
2. T9-style layout on letter keys

```
7 8 9  →  U I O
4 5 6  →  J K L
1 2    →  M ,
0      →  Space

Plus:       ;
Minus:      P
Multiply:   Y
Divide:     H
Enter:      /
```

---

## Learning Path

### Week 1: Master the Basics

**Days 1-2: Shift Overrides**
- Use LeftShift for Escape (Vim users will love this)
- Use RightShift for Backspace
- Old habits will fight back - be patient

**Days 3-4: Home Row Mods**
- Practice holding A for Meta (try: hold A, tap T for terminal)
- Practice holding F for Ctrl (try: hold F, tap C for copy)
- Start with left hand only, then add right hand

**Days 5-7: Layer Awareness**
- Try CODE layer: Press RightAlt, press 7 (Quick Open), press RightAlt
- Try POWER layer oneshot: Tap RightControl, press R (launch editor)

### Week 2: Build Speed

**Focus on muscle memory:**
- Use CODE layer for 10 IDE operations daily
- Use POWER layer for all window switching
- Use NUM layer for calculator app

### Week 3: Advanced Combinations

**Chorded operations:**
- Home row mod + layer key combinations
- Example: Hold F (Ctrl) + RightAlt → CODE layer with Ctrl held

### Week 4: Mastery

**Unconscious competence:**
- No more thinking about layers
- Fingers automatically find the right modifiers
- Significant reduction in finger travel distance

---

## Productivity Metrics

### Finger Travel Reduction

| Action | Traditional | Keyd |
|--------|-------------|------|
| Escape | Pinky to top-left corner | LeftShift (home row) |
| Backspace | Pinky to top-right | RightShift (home row) |
| Ctrl+C | Pinky to corner + C | F + C (home row) |
| Meta+Tab | Thumb to corner + Tab | A + Tab (home row) |
| Window focus | Both hands: Super+arrow | RightControl → HJKL |

### Time Savings

Estimated daily keystroke reduction:
- **Escape key:** ~100 times/day × 2cm travel = 200cm saved
- **Backspace:** ~200 times/day × 3cm travel = 600cm saved
- **Modifiers:** ~500 times/day × 2cm travel = 1000cm saved

**Total:** ~18 meters less finger travel per day!

---

## Troubleshooting Common Issues

### "I keep getting modifiers when I want letters"

**Problem:** Home row mods triggering on fast typing

**Solutions:**
1. Type faster - the 180ms timeout means quick taps register as letters
2. If still problematic, decrease `overload_tap_timeout` in global section
3. Practice rolling fingers instead of pressing down

### "Layers don't feel natural"

**Problem:** Forgetting which layer is active

**Solutions:**
1. Use visual indicators in your desktop (waybar, etc.)
2. Start with oneshot mode for POWER layer (tap RightControl, use one key)
3. Add audio feedback for layer changes (if desired)

### "RightControl is hard to reach"

**Problem:** RightControl location uncomfortable

**Alternative triggers to consider:**
```ini
# In [main] section, pick one:
capslock = oneshot(power)    # Easy to reach
rightalt = toggle(code)      # Already used, but could swap
insert = toggle(power)       # If you don't use Insert
```

### "Menu key doesn't exist on my keyboard"

**Problem:** Physical key missing

**Solutions:**
1. Map NUM layer to another key:
```ini
# In [main] section:
insert = toggle(num)
# OR
capslock = toggle(num)
```

2. Or use Compose key configuration in your DE

---

## Customization Examples

### Add CapsLock as POWER Layer

```ini
# In [main] section:
capslock = oneshot(power)
```

### Add Function Keys to POWER Layer

```ini
# In [power] section:
f1 = M-1
f2 = M-2
# ... etc
```

### Create a Gaming Layer

```ini
# Add to default.conf:

[game]
# Disable all mods for gaming
a = a
s = s
d = d
f = f
j = j
k = k
l = l
semicolon = semicolon

[main]
# Add toggle:
scrolllock = toggle(game)
```

### Email Signatures (Simple Macros)

While full macros aren't built in, you can use the app.conf approach:

```ini
# In app.conf, add application-specific shortcuts:
[ thunderbird ]
# Map unused key to signature
f12 = macro(shift+ctrl+end)
```

---

## Integration with Other Tools

### Hyprland

The POWER layer is designed for Hyprland. Ensure these keybindings exist in `~/.config/hypr/hyprland.conf`:

```ini
# Window management
bind = SUPER, h, movefocus, l
bind = SUPER, j, movefocus, d
bind = SUPER, k, movefocus, u
bind = SUPER, l, movefocus, r

# Workspaces
bind = SUPER, 1, workspace, 1
# ... etc
```

### Neovim

CODE layer assumes standard LSP keybindings. For optimal use, ensure:
- LSP is configured with standard keymaps
- Telescope or similar for file finding
- Which-key for remembering shortcuts

### VSCode/VSCodium

Ensure these keybindings are set:
- `Ctrl+Shift+P` → Command Palette
- `Ctrl+P` → Quick Open
- `Ctrl+Shift+F` → Global Search
- `Meta+B` → Toggle Sidebar

---

## Best Practices

### 1. Start Slow
Don't try to use all layers immediately. Master one at a time.

### 2. Consistency is Key
Use the configuration daily for at least 2 weeks before judging it.

### 3. Customize for Your Workflow
The provided configuration is a starting point. Remove shortcuts you don't use, add ones you need.

### 4. Keep a Cheat Sheet
Print the layer tables and keep them visible until muscle memory develops.

### 5. Use Version Control
Track your configuration changes:
```bash
cd /home/debasmitr/workspace/dotFileV2/install/keyboard
git add keyd/
git commit -m "Customize keyd for my workflow"
```

---

## Advanced Tips

### Layer Indicators

Add to your status bar (waybar, polybar, etc.):
```bash
# Check current keyd state
keyd listen  # outputs layer changes
```

### Conditional Application Behavior

Use the `app.conf` for application-specific tweaks:
```ini
[firefox]
# Firefox-specific remappings

[discord]
# Discord-specific remappings
```

### Multiple Keyboard Support

If you have multiple keyboards, create separate config files:
```bash
sudo mkdir -p /etc/keyd
sudo cp keyd/default.conf /etc/keyd/keychron.conf
sudo cp keyd/default.conf /etc/keyd/laptop.conf

# Edit each with specific [ids] section
```

---

## Resources

- **Keyd Documentation:** `man keyd` or https://github.com/rvaiya/keyd
- **Configuration Validation:** `sudo keyd check /etc/keyd/default.conf`
- **Key Names:** `keyd list-keys`
- **Monitoring:** `sudo keyd monitor`

---

## Version History

- **v1.0** (2026-02-02) - Initial working configuration
  - Fixed all keyd v2.6.0 compatibility issues
  - Validated configuration syntax
  - Working install script

---

## Support

For issues or questions:
1. Validate config: `sudo keyd check /etc/keyd/default.conf`
2. Check service: `sudo systemctl status keyd`
3. Review logs: `sudo journalctl -u keyd`
4. Test with monitor: `sudo keyd monitor`
