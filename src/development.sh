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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    audit_dev_tools
fi
