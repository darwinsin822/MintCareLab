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
