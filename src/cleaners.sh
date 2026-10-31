#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — LIMPIADORES ESPECÍFICOS Y ACOTADOS (src/cleaners.sh)
# ==============================================================================
# REGLA SUPREMA: Cada acción pasa ineludiblemente por security.py
# NUNCA tocar ~/Documentos, ~/Música, ~/Drive, OnlyOffice ni credenciales.
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SEC="${SCRIPT_DIR}/security.py"

# CLEAN-001: Limpieza de Caché de Google Chrome
clean_chrome_cache() {
    local dry_run="${1:-false}"
    local target="$HOME/.cache/google-chrome"
    echo "=== [CLEAN-001] LIMPIEZA DE CACHÉ DE CHROME ==="
    if [[ -d "$target" ]]; then
        local sz
        sz=$(du -sh "$target" 2>/dev/null | cut -f1)
        echo "Tamaño detectado: $sz"
        if [[ "$dry_run" == "true" ]]; then
            python3 "$PYTHON_SEC" dry-delete "$target"
        else
            python3 "$PYTHON_SEC" delete "$target"
            mkdir -p "$target"
        fi
    else
        echo "No se encontró caché de Chrome en $target."
    fi
}

# CLEAN-002: Limpieza de Caché Global de NPM
clean_npm() {
    local dry_run="${1:-false}"
    echo "=== [CLEAN-002] LIMPIEZA DE CACHÉ DE NPM ==="
    source "${SCRIPT_DIR}/development.sh"
    clean_npm_cache "$dry_run"
}

# CLEAN-003: Limpieza de Miniaturas de Cinnamon y Sistema
clean_thumbnails() {
    local dry_run="${1:-false}"
    local target="$HOME/.cache/thumbnails"
    echo "=== [CLEAN-003] LIMPIEZA DE MINIATURAS (THUMBNAILS) ==="
    if [[ -d "$target" ]]; then
        local sz
        sz=$(du -sh "$target" 2>/dev/null | cut -f1)
        echo "Tamaño detectado: $sz"
        if [[ "$dry_run" == "true" ]]; then
            python3 "$PYTHON_SEC" dry-delete "$target"
        else
            python3 "$PYTHON_SEC" delete "$target"
            mkdir -p "$target"
        fi
    else
        echo "No se encontró caché de miniaturas."
    fi
}

# CLEAN-004: Limpieza de Temporales de Dart/Flutter
clean_dart_temp() {
    local dry_run="${1:-false}"
    echo "=== [CLEAN-004] LIMPIEZA DE TEMPORALES DE DART/FLUTTER ==="
    source "${SCRIPT_DIR}/development.sh"
    clean_pub_temp "$dry_run"
}

# CLEAN-005: Limpieza de Temporales de Gradle
clean_gradle_temporary() {
    local dry_run="${1:-false}"
    echo "=== [CLEAN-005] LIMPIEZA DE TEMPORALES DE GRADLE ==="
    source "${SCRIPT_DIR}/development.sh"
    clean_gradle_tmp "$dry_run"
}

# CLEAN-006: Flatpak Unused Runtimes
clean_flatpak_unused() {
    local dry_run="${1:-false}"
    echo "=== [CLEAN-006] LIMPIEZA DE RUNTIMES HUÉRFANOS FLATPAK ==="
    source "${SCRIPT_DIR}/flatpak.sh"
    clean_unused_flatpak "$dry_run"
}

# CLEAN-007: Limpieza Ultra Agresiva de Gradle (Wrappers obsoletos, Caches viejas, JDKs duplicados, Build Cache)
clean_gradle_aggressive() {
    local dry_run="${1:-false}"
    echo "=== [CLEAN-007] LIMPIEZA AGRESIVA DE GRADLE ==="
    source "${SCRIPT_DIR}/development.sh"
    clean_gradle_full "$dry_run"
}

# CLEAN-008: Barrido Seguro de Carpetas Vacías en Cachés
clean_empty_cache_dirs() {
    local dry_run="${1:-false}"
    echo "=== [CLEAN-008] PURGA DE SUBDIRECTORIOS VACÍOS RESIDUALES EN CACHÉS ==="
    python3 -c "
import os, sys
sys.path.insert(0, '${SCRIPT_DIR}')
from security import is_path_protected

safe_roots = [
    os.path.expanduser('~/.gradle'),
    os.path.expanduser('~/.cache'),
    os.path.expanduser('~/.npm')
]

count = 0
for r in safe_roots:
    if not os.path.exists(r) or is_path_protected(r):
        continue
    for root, dirs, files in os.walk(r, topdown=False):
        if is_path_protected(root):
            continue
        for d in dirs:
            dp = os.path.join(root, d)
            if is_path_protected(dp):
                continue
            try:
                if os.path.isdir(dp) and not os.listdir(dp):
                    if '${dry_run}' == 'true':
                        print(f'[SIMULACIÓN] Directorio vacío a remover: {dp}')
                    else:
                        os.rmdir(dp)
                    count += 1
            except Exception:
                pass

print(f'Total de carpetas vacías procesadas en cachés: {count}')
"
}

