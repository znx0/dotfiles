#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.local/share/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=false
MACHINE=""

usage() {
  cat <<'EOF'
Uso:
  ./install.sh [--dry-run] [mainPC|laptop]

Opções:
  --dry-run   Mostra o que seria feito, sem alterar ficheiros nem instalar temas/plugins.
  -h, --help  Mostra esta ajuda.

Se não indicares a máquina, o script pergunta qual a configuração a aplicar.
EOF
}

log() {
  printf '\n==> %s\n' "$*"
}

run_cmd() {
  if "$DRY_RUN"; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

# Regista se alguns ficheiros existiam antes de instalar temas/plugins.
# Isto evita criar backups de ficheiros temporários que esses comandos possam gerar.
declare -A BACKUP_ELIGIBLE=()

backup_file() {
  local target="$1"
  local relative backup

  relative="${target#"$HOME"/}"
  backup="$BACKUP_DIR/$relative"

  if [[ ${BACKUP_ELIGIBLE["$target"]+exists} ]]; then
    [[ "${BACKUP_ELIGIBLE["$target"]}" == "1" ]] || return 0
  else
    [[ -e "$target" || -L "$target" ]] || return 0
  fi

  [[ -e "$target" || -L "$target" ]] || return 0
  [[ -e "$backup" || -L "$backup" ]] && return 0

  if "$DRY_RUN"; then
    printf '[dry-run] Backup: %s -> %s\n' "$target" "$backup"
    return 0
  fi

  mkdir -p -- "$(dirname -- "$backup")"
  cp -a -- "$target" "$backup"
  printf 'Backup: %s\n' "$target"
}

install_file() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    printf 'ERRO: ficheiro de origem não encontrado: %s\n' "$source" >&2
    return 1
  fi

  backup_file "$target"

  if "$DRY_RUN"; then
    printf '[dry-run] Copiaria: %s -> %s\n' "$source" "$target"
    return 0
  fi

  mkdir -p -- "$(dirname -- "$target")"
  cp -- "$source" "$target"
  printf 'Aplicado: %s\n' "$target"
}

install_tree() {
  local source_dir="$1"
  local target_dir="$2"
  local source_file relative target

  [[ -d "$source_dir" ]] || return 0

  while IFS= read -r -d '' source_file; do
    relative="${source_file#"$source_dir"/}"
    target="$target_dir/$relative"
    backup_file "$target"

    if "$DRY_RUN"; then
      printf '[dry-run] Copiaria: %s -> %s\n' "$source_file" "$target"
    else
      mkdir -p -- "$(dirname -- "$target")"
      cp -a -- "$source_file" "$target"
      printf 'Aplicado: %s\n' "$target"
    fi
  done < <(find "$source_dir" \( -type f -o -type l \) -print0)
}

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    mainPC|laptop)
      if [[ -n "$MACHINE" ]]; then
        printf 'ERRO: indica apenas uma máquina (mainPC ou laptop).\n' >&2
        exit 1
      fi
      MACHINE="$1"
      ;;
    *)
      printf 'Argumento desconhecido: %s\n\n' "$1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$MACHINE" ]]; then
  printf 'Que configuração queres aplicar?\n'
  printf '  1) mainPC\n'
  printf '  2) laptop\n'
  read -r -p 'Escolhe [1-2]: ' choice

  case "$choice" in
    1) MACHINE="mainPC" ;;
    2) MACHINE="laptop" ;;
    *)
      printf 'Escolha inválida.\n' >&2
      exit 1
      ;;
  esac
fi

MONITORS_FILE="$ROOT/machine-specific/$MACHINE/monitors.lua"

if [[ ! -f "$MONITORS_FILE" ]]; then
  printf 'ERRO: não encontrei a configuração dos monitores: %s\n' "$MONITORS_FILE" >&2
  exit 1
fi

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'ERRO: o comando omarchy não foi encontrado. Este script deve ser executado num sistema Omarchy.\n' >&2
  exit 1
fi

if "$DRY_RUN"; then
  log "Modo dry-run: não serão feitas alterações."
else
  log "Configuração selecionada: $MACHINE"
  log "Os backups serão guardados em: $BACKUP_DIR"
fi

# Guardar o estado original antes de os comandos de plugins poderem alterar shell.json.
for target in "$HOME/.config/omarchy/shell.json" "$HOME/.config/omarchy/shell.toml"; do
  if [[ -e "$target" || -L "$target" ]]; then
    BACKUP_ELIGIBLE["$target"]="1"
    backup_file "$target"
  else
    BACKUP_ELIGIBLE["$target"]="0"
  fi
done

log "Instalar temas Omarchy"
while IFS='|' read -r name repo || [[ -n "${name:-}${repo:-}" ]]; do
  [[ -z "${name:-}" || "$name" == \#* ]] && continue
  [[ -z "${repo:-}" ]] && continue

  target="$HOME/.config/omarchy/themes/$name"
  if [[ -d "$target" ]]; then
    printf 'Já instalado: %s\n' "$name"
  else
    run_cmd omarchy theme install "$repo"
  fi
done < "$ROOT/themes/themes.txt"

log "Instalar plugins Omarchy"
while IFS='|' read -r id repo || [[ -n "${id:-}${repo:-}" ]]; do
  [[ -z "${id:-}" || "$id" == \#* ]] && continue
  [[ -z "${repo:-}" ]] && continue

  target="$HOME/.config/omarchy/plugins/$id"
  if [[ -d "$target" ]]; then
    run_cmd omarchy plugin enable "$id"
  else
    run_cmd omarchy plugin add "$repo" --enable --yes
  fi
done < "$ROOT/plugins/plugins.txt"

log "Aplicar configurações Hyprland"
install_tree "$ROOT/configs/hypr" "$HOME/.config/hypr"
install_file "$MONITORS_FILE" "$HOME/.config/hypr/monitors.lua"

log "Aplicar configuração Ghostty"
if [[ -f "$ROOT/configs/ghostty/config" ]]; then
  install_file "$ROOT/configs/ghostty/config" "$HOME/.config/ghostty/config"
else
  printf 'Ignorado: não existe configs/ghostty/config no repositório.\n'
fi

log "Aplicar configuração Omarchy"
for file in shell.json shell.toml; do
  if [[ -f "$ROOT/configs/omarchy/$file" ]]; then
    install_file "$ROOT/configs/omarchy/$file" "$HOME/.config/omarchy/$file"
  else
    printf 'Ignorado: não existe configs/omarchy/%s no repositório.\n' "$file"
  fi
done

# Estas personalizações só fazem sentido se a camada Black omARCHy estiver instalada.
if [[ -f /var/lib/blackomarchy/version ]]; then
  log "Aplicar personalizações Black omARCHy"
  install_tree "$ROOT/configs/omarchy/branding" "$HOME/.config/omarchy/branding"

  if [[ -f "$ROOT/configs/omarchy/extensions/omarchy-menu.jsonc" ]]; then
    install_file "$ROOT/configs/omarchy/extensions/omarchy-menu.jsonc" \
      "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
  fi

  install_tree "$ROOT/configs/omarchy/hooks" "$HOME/.config/omarchy/hooks"
else
  printf '\nBlack omARCHy não detetado; personalizações específicas ignoradas.\n'
fi

# Configuração específica de uv/Fish, apenas quando o ambiente local existe.
if [[ -f "$HOME/.local/bin/env.fish" && -f "$ROOT/configs/fish/conf.d/uv.env.fish" ]]; then
  log "Aplicar configuração Fish para uv"
  install_file "$ROOT/configs/fish/conf.d/uv.env.fish" \
    "$HOME/.config/fish/conf.d/uv.env.fish"
else
  printf '\nConfiguração Fish/uv ignorada (ficheiro de ambiente ou configuração não encontrado).\n'
fi

log "Copiar wallpapers"
install_tree "$ROOT/wallpapers" "$HOME/Wallpapers"

# Instalar o hook opcional do plugin Cursor Accent, caso esteja disponível.
CURSOR_HOOK="$HOME/.config/omarchy/plugins/io.github.smoothpixels.cursor-accent/tools/install-cursor-hook.sh"
if [[ -x "$CURSOR_HOOK" ]]; then
  log "Instalar hook do Cursor Accent"
  run_cmd "$CURSOR_HOOK"
else
  printf '\nHook do Cursor Accent não encontrado/executável; ignorado.\n'
fi

log "Selecionar tema Ayaka"
if [[ -d "$HOME/.config/omarchy/themes/ayaka" ]] || "$DRY_RUN"; then
  run_cmd omarchy theme set ayaka
else
  printf 'Tema Ayaka não está instalado; não foi possível selecioná-lo.\n'
fi

if "$DRY_RUN"; then
  printf '\nDry-run concluído. Não foram alterados ficheiros nem instalados temas/plugins.\n'
else
  printf '\nInstalação concluída para: %s\n' "$MACHINE"
  printf 'Backups (quando aplicável): %s\n' "$BACKUP_DIR"
fi
