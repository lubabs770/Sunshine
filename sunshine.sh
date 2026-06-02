#!/usr/bin/env bash
# sunshine — unified theme switcher
# deps: gum (auto-installed), python3, sqlite3, osascript, sed, defaults

set -uo pipefail

# ── paths ─────────────────────────────────────────────────────────────────────

WALLPAPER_DIR="$HOME/Personal/wallpaper/pastels"
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
VSCODE_EXT_DIR="$HOME/.vscode/extensions"
ZED_SETTINGS="$HOME/.config/zed/settings.json"
NVIM_UI_PLUGIN="$HOME/.config/nvim/lua/plugins/astroui.lua"
YAZI_THEME_FILE="$HOME/.config/yazi/theme.toml"
YAZI_FLAVORS_DIR="$HOME/.config/yazi/flavors"
BTOP_CONF="$HOME/.config/btop/btop.conf"
BTOP_THEMES_DIR="$HOME/.config/btop/themes"
NEOFETCH_CONF="$HOME/.config/neofetch/config.conf"
BORDERS_COLOR_FILE="$HOME/.config/borders/active_color"
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"
ALACRITTY_THEMES_DIR="$HOME/.config/alacritty/themes"
SB_WEBKIT_ROOT="$HOME/Library/WebKit/tracesOf.Uebersicht"
SUNSHINE_STATE="$HOME/.config/sunshine-theme"

# ── bootstrap ─────────────────────────────────────────────────────────────────

command -v gum &>/dev/null || brew install gum

if [[ "${1:-}" == "bootstrap" ]]; then
    exec "$HOME/.config/sunshine-bootstrap"
fi

# ── theme data ────────────────────────────────────────────────────────────────

declare -A LABELS ACCENTS BORDER_COLORS SIMPLEBAR_THEMES
declare -A VSCODE_EXT_PREFIXES VSCODE_THEMES ZED_THEMES ITERM_PRESETS
declare -A NVIM_SCHEMES YAZI_FLAVORS_MAP NEOFETCH_COLORS BTOP_THEMES_MAP WALLPAPER_PREFIXES
declare -A ALACRITTY_THEMES

LABELS=(
  [nord]="Nord"              [tokyo]="Tokyo Night"
  [gruvbox]="Gruvbox"       [rose]="Rose Pine"
  [catppuccin]="Catppuccin Frappé"
  [kanagawa]="Kanagawa"     [everforest]="Everforest"
)
ACCENTS=(
  [nord]="#88c0d0"   [tokyo]="#7aa2f7"   [gruvbox]="#fabd2f"
  [rose]="#eb6f92"   [catppuccin]="#ca9ee6"
  [kanagawa]="#7e9cd8" [everforest]="#a7c080"
)
BORDER_COLORS=(
  [nord]="0xff88c0d0"   [tokyo]="0xff7aa2f7"   [gruvbox]="0xfffabd2f"
  [rose]="0xffeb6f92"   [catppuccin]="0xffca9ee6"
  [kanagawa]="0xff7e9cd8" [everforest]="0xffa7c080"
)
SIMPLEBAR_THEMES=(
  [nord]="Nord"              [tokyo]="TokyoNight"
  [gruvbox]="GruvboxDark"   [rose]="RosePine"
  [catppuccin]="CatppuccinFrappe"
  [kanagawa]="TokyoNight"   [everforest]="GruvboxMaterial"
)
VSCODE_EXT_PREFIXES=(
  [nord]="arcticicestudio"   [tokyo]="enkia"
  [gruvbox]="jdinhlife"      [rose]="mvllow"
  [catppuccin]="catppuccin"  [kanagawa]="qufiwefefwoyn"
  [everforest]="sainnhe"
)
VSCODE_THEMES=(
  [nord]="Nord"                    [tokyo]="Tokyo Night"
  [gruvbox]="Gruvbox Dark Hard"    [rose]="Rosé Pine"
  [catppuccin]="Catppuccin Frappé" [kanagawa]="Kanagawa"
  [everforest]="Everforest Dark"
)
ZED_THEMES=(
  [nord]="Nord"                    [tokyo]="Tokyo Night"
  [gruvbox]="Gruvbox"              [rose]="Rosé Pine"
  [catppuccin]="Catppuccin Frappé" [kanagawa]="Kanagawa"
  [everforest]="Everforest"
)
ITERM_PRESETS=(
  [nord]="Nord"                    [tokyo]="Tokyo Night"
  [gruvbox]="Gruvbox Dark Hard"    [rose]="Rosé Pine"
  [catppuccin]="Catppuccin Frappe" [kanagawa]="Kanagawa"
  [everforest]="Everforest"
)
NVIM_SCHEMES=(
  [nord]="nord"          [tokyo]="tokyonight"
  [gruvbox]="gruvbox"    [rose]="rose-pine"
  [catppuccin]="catppuccin" [kanagawa]="kanagawa"
  [everforest]="everforest"
)
YAZI_FLAVORS_MAP=(
  [nord]="nord"              [tokyo]="tokyo-night"
  [gruvbox]="gruvbox-dark"   [rose]="rose-pine"
  [catppuccin]="catppuccin-frappe" [kanagawa]="kanagawa"
  [everforest]="everforest-medium"
)
NEOFETCH_COLORS=(
  [nord]="6 4 6 4 4 6"       [tokyo]="4 5 4 6 4 5"
  [gruvbox]="3 1 2 5 4 6"    [rose]="5 1 5 6 5 1"
  [catppuccin]="5 6 5 4 5 6" [kanagawa]="4 6 4 4 4 6"
  [everforest]="2 3 2 6 2 3"
)
BTOP_THEMES_MAP=(
  [nord]="Nord"                  [tokyo]="tokyo-night"
  [gruvbox]="gruvbox"            [rose]="rose-pine"
  [catppuccin]="catppuccin-frappe" [kanagawa]="kanagawa"
  [everforest]="everforest"
)
WALLPAPER_PREFIXES=(
  [nord]="nord-"         [tokyo]="tokyo-night-"
  [gruvbox]="gruvbox-"   [rose]="rose-pine-"
  [catppuccin]="catppuccin-" [kanagawa]="kanagawa-"
  [everforest]="everforest-"
)
ALACRITTY_THEMES=(
  [nord]="nord"                  [tokyo]="tokyo_night"
  [gruvbox]="gruvbox_dark"       [rose]="rose_pine"
  [catppuccin]="catppuccin_frappe" [kanagawa]="kanagawa_wave"
  [everforest]="everforest_dark"
)

# ── output helpers ────────────────────────────────────────────────────────────

ok()   { gum style --foreground="#a6e3a1" "  ✓ $*"; }
warn() { gum style --foreground="#f9e2af" "  ⚠ $*"; }

# ── picker ────────────────────────────────────────────────────────────────────

BANNER=$(cat <<'BANNER_EOF'
   \  :  /       \  :  /       \  :  /       \  :  /       \  :  /
`. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .'
_ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _
   /_   _\       /_   _\       /_   _\       /_   _\       /_   _\
 .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.
   /  |  \       /  :  \       /  :  \       /  :  \       /  |  \
      |                                                       |
   \  |  /                                                 \  |  /
`. __/ \__ .'                                           `. __/ \__ .'
_ _\     /_ _                                           _ _\     /_ _
   /_   _\                                                 /_   _\
 .'  \ /  `.                            _    _           .'  \ /  `.
   /  |  \         ____  _ _ _  __| |_ (_)_ _  ___         /  |  \
      |           (_-< || | ' \(_-< ' \| | ' \/ -_)           |
   \  |  /        /__/\_,_|_||_/__/_||_|_|_||_\___|        \  |  /
`. __/ \__ .'                                           `. __/ \__ .'
_ _\     /_ _                                           _ _\     /_ _
   /_   _\                                                 /_   _\
 .'  \ /  `.                                             .'  \ /  `.
   /  |  \                                                 /  |  \
      |                                                       |
   \  |  /       \  :  /       \  :  /       \  :  /       \  |  /
`. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .' `. __/ \__ .'
_ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _ _ _\     /_ _
   /_   _\       /_   _\       /_   _\       /_   _\       /_   _\
 .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.   .'  \ /  `.
   /  :  \       /  :  \       /  :  \       /  :  \       /  :  \
BANNER_EOF
)

_LABELS=("Nord" "Tokyo Night" "Gruvbox" "Rose Pine" "Catppuccin Frappé" "Kanagawa" "Everforest" "⚙  Bootstrap")
_KEYS=(nord tokyo gruvbox rose catppuccin kanagawa everforest bootstrap)
ACCENTS[bootstrap]="#a6adc8"

_hex_fg() {
    local h="${1#\#}"
    printf '\033[38;2;%d;%d;%dm' $((16#${h:0:2})) $((16#${h:2:2})) $((16#${h:4:2}))
}
_RST=$'\033[0m'
_BLD=$'\033[1m'

_draw() {
    local idx=$1 key clr
    key="${_KEYS[$idx]}"
    clr=$(_hex_fg "${ACCENTS[$key]}")
    printf '%s%s%s\n' "$clr" "$BANNER" "$_RST"
    echo ""
    local i
    for i in "${!_LABELS[@]}"; do
        if [[ $i -eq $idx ]]; then
            printf '%s%s▸ %s%s\n' "$_BLD" "$clr" "${_LABELS[$i]}" "$_RST"
        else
            printf '  %s\n' "${_LABELS[$i]}"
        fi
    done
    printf '\n\033[38;2;108;112;134m  j ↓   k ↑   enter select   q quit\033[0m\n'
}

_BANNER_H=$(printf '%s\n' "$BANNER" | wc -l)
_TOTAL_H=$(( _BANNER_H + 1 + ${#_LABELS[@]} + 2 ))

_saved=$(awk -F: '{print $1}' "$SUNSHINE_STATE" 2>/dev/null || echo "")
_sel=0
for _i in "${!_KEYS[@]}"; do
    [[ "${_KEYS[$_i]}" == "$_saved" ]] && { _sel=$_i; break; }
done

trap 'tput cnorm; echo ""; exit 0' INT TERM
tput civis
_draw "$_sel"

while true; do
    IFS= read -rsn1 _ch || { tput cnorm; echo ""; exit 0; }
    case "$_ch" in
        $'\x1b')
            IFS= read -rsn2 -t 0.05 _seq || true
            if   [[ "$_seq" == $'[A' ]]; then (( _sel > 0 )) && (( _sel-- )) || true
            elif [[ "$_seq" == $'[B' ]]; then (( _sel < ${#_LABELS[@]} - 1 )) && (( _sel++ )) || true
            fi ;;
        '' | $'\r')
            KEY="${_KEYS[$_sel]}"
            break ;;
        k)
            (( _sel > 0 )) && (( _sel-- )) || true ;;
        j)
            (( _sel < ${#_LABELS[@]} - 1 )) && (( _sel++ )) || true ;;
        q)
            tput cnorm; echo ""; exit 0 ;;
    esac
    printf '\033[%dF' $_TOTAL_H
    _draw "$_sel"
done

tput cnorm
printf '\n'

if [[ "$KEY" == "bootstrap" ]]; then
    exec "$HOME/.config/sunshine-bootstrap"
fi

printf '%s:%s\n' "$KEY" "${ACCENTS[$KEY]}" > "$SUNSHINE_STATE"

# ── apply: borders ────────────────────────────────────────────────────────────

apply_borders() {
  command -v borders &>/dev/null || { warn "borders — not installed"; return; }
  [ -f "$BORDERS_COLOR_FILE" ] || mkdir -p "$(dirname "$BORDERS_COLOR_FILE")"
  local color="${BORDER_COLORS[$KEY]}"
  printf '%s\n' "$color" > "$BORDERS_COLOR_FILE"
  borders active_color="$color" &>/dev/null || true
  ok "borders"
}

# ── apply: simple-bar ─────────────────────────────────────────────────────────

apply_simplebar() {
  osascript -e 'tell application "Übersicht" to true' &>/dev/null \
    || { warn "simple-bar — Übersicht not running"; return; }

  local db
  db=$(find "$SB_WEBKIT_ROOT" -name "localstorage.sqlite3" 2>/dev/null | while read -r f; do
    sqlite3 "$f" "SELECT key FROM ItemTable WHERE key='simple-bar-settings'" 2>/dev/null \
      | grep -q . && printf '%s\n' "$f" && break
  done)
  [ -n "$db" ] || { warn "simple-bar — localStorage DB not found"; return; }

  local sb_theme="${SIMPLEBAR_THEMES[$KEY]}"
  python3 - "$db" "$sb_theme" <<'PYEOF'
import sqlite3, sys, json

db_path, new_theme = sys.argv[1], sys.argv[2]

def decode(val):
    return val.decode('utf-16-le') if isinstance(val, bytes) else val

def encode(s):
    return s.encode('utf-16-le')

conn = sqlite3.connect(db_path)
row = conn.execute("SELECT value FROM ItemTable WHERE key='simple-bar-settings'").fetchone()
if not row:
    sys.exit(1)
data = json.loads(decode(row[0]))
data['themes']['darkTheme'] = new_theme
new_json = json.dumps(data, separators=(',', ':'))
conn.execute("UPDATE ItemTable SET value=? WHERE key='simple-bar-settings'", (encode(new_json),))
conn.commit()
conn.close()
PYEOF

  osascript -e 'tell application "Übersicht" to refresh widget id "simple-bar-index-jsx"' &>/dev/null || true
  ok "simple-bar"
}

# ── apply: VS Code ────────────────────────────────────────────────────────────

apply_vscode() {
  [ -f "$VSCODE_SETTINGS" ] || { warn "VS Code — settings.json not found"; return; }
  local ext_prefix="${VSCODE_EXT_PREFIXES[$KEY]}"
  ls "$VSCODE_EXT_DIR" 2>/dev/null | grep -qi "$ext_prefix" || {
    warn "VS Code — ${LABELS[$KEY]} extension not installed (need: $ext_prefix.*)"; return
  }
  local theme="${VSCODE_THEMES[$KEY]}"
  sed -i '' 's|"workbench.colorTheme": ".*"|"workbench.colorTheme": "'"$theme"'"|' "$VSCODE_SETTINGS"
  ok "VS Code"
}

# ── apply: Zed ────────────────────────────────────────────────────────────────

apply_zed() {
  [ -f "$ZED_SETTINGS" ] || { warn "Zed — settings.json not found"; return; }
  local theme="${ZED_THEMES[$KEY]}"
  sed -i '' '/^  "theme":/,/^  },/ s|"dark": ".*"|"dark": "'"$theme"'"|' "$ZED_SETTINGS"
  ok "Zed"
}

# ── apply: iTerm2 ─────────────────────────────────────────────────────────────

apply_iterm() {
  local preset="${ITERM_PRESETS[$KEY]}"
  (ITERM_CHECK_PRESET="$preset" python3 <<'PYEOF'
import subprocess, plistlib, unicodedata, os, sys
name = unicodedata.normalize('NFC', os.environ['ITERM_CHECK_PRESET'])
r = subprocess.run(['defaults','export','com.googlecode.iterm2','-'], capture_output=True)
prefs = plistlib.loads(r.stdout)
presets = prefs.get('Custom Color Presets', {})
sys.exit(0 if any(unicodedata.normalize('NFC', k) == name for k in presets) else 1)
PYEOF
  ) 2>/dev/null || { warn "iTerm2 — preset '$preset' not imported"; return; }
  osascript 2>/dev/null <<EOF || { warn "iTerm2 — not running or no active window"; return; }
tell application "iTerm2"
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        tell s to set color preset to "$preset"
      end repeat
    end repeat
  end repeat
end tell
EOF
  ok "iTerm2"
}

# ── apply: nvim ───────────────────────────────────────────────────────────────

apply_nvim() {
  [ -f "$NVIM_UI_PLUGIN" ] || { warn "nvim — astroui.lua not found"; return; }
  local scheme="${NVIM_SCHEMES[$KEY]}"
  sed -i '' 's|colorscheme = ".*"|colorscheme = "'"$scheme"'"|' "$NVIM_UI_PLUGIN"
  ok "nvim  (restart to apply)"
}

# ── apply: yazi ───────────────────────────────────────────────────────────────

apply_yazi() {
  [ -f "$YAZI_THEME_FILE" ] || { warn "yazi — theme.toml not found"; return; }
  local flavor="${YAZI_FLAVORS_MAP[$KEY]}"
  [ -n "$flavor" ] || { warn "yazi — no flavor mapping for ${LABELS[$KEY]}"; return; }
  [ -d "$YAZI_FLAVORS_DIR/$flavor.yazi" ] || {
    warn "yazi — flavor '$flavor' not installed (run: ya pkg add $flavor)"; return
  }
  python3 - "$YAZI_THEME_FILE" "$flavor" <<'PYEOF'
import re, sys
theme_file, flavor = sys.argv[1], sys.argv[2]
with open(theme_file) as f:
    content = f.read()
# Remove any existing [flavor] section (up to next section or EOF)
content = re.sub(r'\n*\[flavor\].*?(?=\n\[|\Z)', '', content, flags=re.DOTALL).rstrip()
content += f'\n\n[flavor]\nuse = "{flavor}"\n'
with open(theme_file, 'w') as f:
    f.write(content)
PYEOF
  ok "yazi"
}

# ── apply: neofetch ───────────────────────────────────────────────────────────

apply_neofetch() {
  [ -f "$NEOFETCH_CONF" ] || { warn "neofetch — config.conf not found"; return; }
  local colors="${NEOFETCH_COLORS[$KEY]}"
  sed -i '' 's|^colors=([^)]*)|colors=('"$colors"')|' "$NEOFETCH_CONF"
  ok "neofetch"
}

# ── apply: btop ───────────────────────────────────────────────────────────────

apply_btop() {
  [ -f "$BTOP_CONF" ] || { warn "btop — btop.conf not found"; return; }
  local theme="${BTOP_THEMES_MAP[$KEY]}"
  [ -n "$theme" ] || { warn "btop — no theme mapping for ${LABELS[$KEY]}"; return; }
  [ -f "$BTOP_THEMES_DIR/$theme.theme" ] || {
    warn "btop — '$theme.theme' not found in $BTOP_THEMES_DIR"; return
  }
  sed -i '' 's|^color_theme = ".*"|color_theme = "'"$theme"'"|' "$BTOP_CONF"
  ok "btop"
}

# ── apply: alacritty ──────────────────────────────────────────────────────────

apply_alacritty() {
  local theme="${ALACRITTY_THEMES[$KEY]}"
  local theme_path="$ALACRITTY_THEMES_DIR/$theme.toml"
  local current="$ALACRITTY_THEMES_DIR/current.toml"
  [ -f "$theme_path" ] || {
    warn "alacritty — theme '$theme.toml' not in $ALACRITTY_THEMES_DIR"; return
  }
  # alacritty.toml always imports current.toml (stable path — never changes after first run)
  if [ ! -f "$ALACRITTY_CONF" ]; then
    mkdir -p "$(dirname "$ALACRITTY_CONF")"
    printf '[general]\nimport = ["%s"]\n' "$current" > "$ALACRITTY_CONF"
  else
    python3 - "$ALACRITTY_CONF" "$current" <<'PYEOF'
import re, sys
conf, current = sys.argv[1], sys.argv[2]
with open(conf) as f:
    content = f.read()
new_line = f'import = ["{current}"]'
lines = content.splitlines(keepends=True)
new_lines = []
in_general = False
import_written = False
for line in lines:
    stripped = line.strip()
    if stripped.startswith('['):
        in_general = (stripped == '[general]')
    if in_general and re.match(r'^\s*import\s*=\s*\[', line):
        new_lines.append(new_line + '\n')
        import_written = True
    elif not in_general and re.match(r'^import\s*=\s*\[', line):
        pass  # migrate old top-level import
    else:
        new_lines.append(line)
result = ''.join(new_lines)
if not import_written:
    if '[general]' in result:
        result = re.sub(r'(\[general\]\n?)', f'\\1{new_line}\n', result, count=1)
    else:
        result = f'[general]\n{new_line}\n\n' + result.lstrip()
with open(conf, 'w') as f:
    f.write(result)
PYEOF
  fi
  # Write theme into current.toml in-place (preserves inode → all open windows hot-reload)
  python3 - "$theme_path" "$current" <<'PYEOF'
import sys
with open(sys.argv[1]) as src:
    content = src.read()
try:
    with open(sys.argv[2], 'r+') as f:
        f.seek(0); f.write(content); f.truncate()
except FileNotFoundError:
    with open(sys.argv[2], 'w') as f:
        f.write(content)
PYEOF
  ok "alacritty"
}

# ── apply: wallpaper ──────────────────────────────────────────────────────────

apply_wallpaper() {
  [ -d "$WALLPAPER_DIR" ] || { warn "wallpaper — dir not found: $WALLPAPER_DIR"; return; }
  local prefix="${WALLPAPER_PREFIXES[$KEY]}"

  mapfile -t walls < <(ls "$WALLPAPER_DIR"/${prefix}* 2>/dev/null || true)
  [ "${#walls[@]}" -gt 0 ] || {
    warn "wallpaper — no files matching '${prefix}*' in $WALLPAPER_DIR"; return
  }

  local desktop_count
  desktop_count=$(osascript -e 'tell application "System Events" to count of desktops' 2>/dev/null) || {
    warn "wallpaper — couldn't get desktop count"; return
  }

  local applied=()
  for ((i=1; i<=desktop_count; i++)); do
    local wall="${walls[$((RANDOM % ${#walls[@]}))]}"
    osascript -e "tell application \"System Events\" to set picture of desktop $i to \"$wall\"" &>/dev/null || true
    applied+=("$(basename "$wall")")
  done

  ok "wallpaper → ${applied[*]}"
}

# ── run ───────────────────────────────────────────────────────────────────────

echo ""
gum style \
  --foreground="${ACCENTS[$KEY]}" \
  --bold \
  "  ☀  ${LABELS[$KEY]}"
echo ""

apply_borders
apply_simplebar
apply_vscode
apply_zed
apply_iterm
apply_nvim
apply_yazi
apply_neofetch
apply_btop
apply_alacritty
apply_wallpaper

echo ""
