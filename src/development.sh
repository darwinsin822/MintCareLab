#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — HERRAMIENTAS Y CACHÉS DE DESARROLLO (src/development.sh)
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SEC="${SCRIPT_DIR}/security.py"

audit_dev_tools() {
    echo "=== AUDITORÍA DE HERRAMIENTAS Y CACHÉS DE DESARROLLO ==="
    
    # 1. NPM
    if [[ -d "$HOME/.npm" ]]; then
        local npm_sz
        npm_sz=$(du -sh "$HOME/.npm" 2>/dev/null | cut -f1)
        echo "[NPM] Caché global (~/.npm): $npm_sz"
        echo "      _cacache: $(du -sh "$HOME/.npm/_cacache" 2>/dev/null | cut -f1 || echo '0 B')"
        echo "      _npx:     $(du -sh "$HOME/.npm/_npx" 2>/dev/null | cut -f1 || echo '0 B')"
    fi

    # 2. GRADLE
    if [[ -d "$HOME/.gradle" ]]; then
        local gradle_sz
        gradle_sz=$(du -sh "$HOME/.gradle" 2>/dev/null | cut -f1)
        echo "[Gradle] Directorio global (~/.gradle): $gradle_sz"
        echo "         Wrapper dists: $(du -sh "$HOME/.gradle/wrapper/dists" 2>/dev/null | cut -f1 || echo '0 B')"
        echo "         JDKs descargados: $(du -sh "$HOME/.gradle/jdks" 2>/dev/null | cut -f1 || echo '0 B')"
        echo "         Archivos temporales: $(du -sh "$HOME/.gradle/.tmp" 2>/dev/null | cut -f1 || echo '0 B')"
    fi

    # 3. ANDROID SDK
    if [[ -d "$HOME/Android/Sdk" ]]; then
        local sdk_sz
        sdk_sz=$(du -sh "$HOME/Android/Sdk" 2>/dev/null | cut -f1)
        echo "[Android SDK] Ubicación (~/Android/Sdk): $sdk_sz"
    fi

    # 4. FLUTTER & DART
    if [[ -d "$HOME/.pub-cache" ]]; then
        local pub_sz
        pub_sz=$(du -sh "$HOME/.pub-cache" 2>/dev/null | cut -f1)
        echo "[Flutter/Dart] Pub Cache (~/.pub-cache): $pub_sz"
        echo "               _temp: $(du -sh "$HOME/.pub-cache/_temp" 2>/dev/null | cut -f1 || echo '0 B')"
    fi

    # 5. RUST & CARGO
    if [[ -d "$HOME/.cargo" ]]; then
        local cargo_sz
        cargo_sz=$(du -sh "$HOME/.cargo" 2>/dev/null | cut -f1)
        echo "[Cargo] Caché de crates (~/.cargo): $cargo_sz"
    fi
}

clean_npm_cache() {
    local dry_run="${1:-false}"
    echo "--- Limpieza de Caché de NPM ---"
    if [[ "$dry_run" == "true" ]]; then
        python3 "$PYTHON_SEC" dry-delete "$HOME/.npm/_cacache"
        python3 "$PYTHON_SEC" dry-delete "$HOME/.npm/_npx"
    else
        python3 "$PYTHON_SEC" delete "$HOME/.npm/_cacache"
        python3 "$PYTHON_SEC" delete "$HOME/.npm/_npx"
        echo "[ÉXITO] Caché de NPM limpiada."
    fi
}

clean_pub_temp() {
    local dry_run="${1:-false}"
    echo "--- Limpieza de Temporales de Dart/Flutter ---"
    if [[ -d "$HOME/.pub-cache/_temp" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            python3 "$PYTHON_SEC" dry-delete "$HOME/.pub-cache/_temp"
        else
            python3 "$PYTHON_SEC" delete "$HOME/.pub-cache/_temp"
            mkdir -p "$HOME/.pub-cache/_temp"
            echo "[ÉXITO] Temporales de Pub-cache eliminados."
        fi
    fi
}

clean_gradle_tmp() {
    local dry_run="${1:-false}"
    echo "--- Limpieza de Temporales de Gradle ---"
    if [[ -d "$HOME/.gradle/.tmp" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            python3 "$PYTHON_SEC" dry-delete "$HOME/.gradle/.tmp"
        else
            python3 "$PYTHON_SEC" delete "$HOME/.gradle/.tmp"
            mkdir -p "$HOME/.gradle/.tmp"
            echo "[ÉXITO] Directorio temporal de Gradle purgado."
        fi
    fi
}

clean_gradle_full() {
    local dry_run="${1:-false}"
    echo "--- Limpieza Ultra Agresiva de Gradle ---"
    python3 -c "
import os, sys
from pathlib import Path
sys.path.insert(0, '${SCRIPT_DIR}')
from security import safe_delete

dry = ('${dry_run}' == 'true')

# 1. Wrappers obsoletos (conservar gradle-9.7.1-bin activo)
wrapper_dir = Path.home() / '.gradle' / 'wrapper' / 'dists'
keep_wrapper = 'gradle-9.7.1-bin'
if wrapper_dir.exists():
    for item in wrapper_dir.iterdir():
        if item.name != keep_wrapper and item.is_dir():
            print(f'Eliminando wrapper obsoleto: {item}')
            safe_delete(str(item), dry_run=dry)

# 2. Caches obsoletas (8.*, 9.1.*, 9.8.*)
caches_dir = Path.home() / '.gradle' / 'caches'
obsolete_versions = {'8.5', '8.12', '9.1.0', '9.8.2'}
if caches_dir.exists():
    for item in caches_dir.iterdir():
        if item.name in obsolete_versions and item.is_dir():
            print(f'Eliminando caché obsoleta: {item}')
            safe_delete(str(item), dry_run=dry)

# 3. build-cache-1
b_cache = caches_dir / 'build-cache-1'
if b_cache.exists():
    print(f'Eliminando build-cache-1: {b_cache}')
    safe_delete(str(b_cache), dry_run=dry)

# 4. JDKs redundantes y tarballs
jdks_dir = Path.home() / '.gradle' / 'jdks'
if jdks_dir.exists():
    for item in jdks_dir.iterdir():
        if item.name != 'CACHEDIR.TAG':
            print(f'Eliminando JDK/tarball descargado: {item}')
            safe_delete(str(item), dry_run=dry)

# 5. Daemons viejos
daemon_dir = Path.home() / '.gradle' / 'daemon'
if daemon_dir.exists():
    for item in daemon_dir.iterdir():
        if item.is_dir() and item.name != '9.7.1':
            print(f'Eliminando daemon antiguo: {item}')
            safe_delete(str(item), dry_run=dry)
"
    echo "[ÉXITO] Limpieza agresiva de Gradle finalizada."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    audit_dev_tools
fi

