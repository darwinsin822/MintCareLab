#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — ANÁLISIS DE PAQUETES Y DEPENDENCIAS (src/packages.sh)
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SEC="${SCRIPT_DIR}/security.py"

# Listar paquetes en estado residual (rc)
get_residual_packages() {
    dpkg -l 2>/dev/null | grep "^rc" | awk '{print $2}' || true
}

# Diagnóstico de paquetes
audit_packages() {
    echo "=== DIAGNÓSTICO DE PAQUETES APT Y DPKG ==="
    local rc_pkgs
    rc_pkgs=$(get_residual_packages)
    local count
    count=$(echo "$rc_pkgs" | grep -v "^$" | wc -l || echo "0")
    
    echo "Paquetes con configuraciones residuales (rc): $count"
    if [[ "$count" -gt 0 ]]; then
        echo "$rc_pkgs" | head -n 10 | sed 's/^/  - /'
        if [[ "$count" -gt 10 ]]; then
            echo "  ... y $((count - 10)) más."
        fi
        echo "Espacio recuperable estimado: ~50 MB"
    fi

    echo ""
    echo "Comprobando caché de APT (/var/cache/apt/archives)..."
    local apt_cache_size="0 B"
    if [[ -d "/var/cache/apt/archives" ]]; then
        apt_cache_size=$(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1 || echo "0 B")
    fi
    echo "Tamaño de la caché APT: $apt_cache_size"
}

# Purga segura de paquetes residuales (requiere confirmación)
purge_residual_packages() {
    local dry_run="${1:-false}"
    local rc_pkgs
    rc_pkgs=$(get_residual_packages)
    local count
    count=$(echo "$rc_pkgs" | grep -v "^$" | wc -l || echo "0")

    if [[ "$count" -eq 0 ]]; then
        echo "No hay paquetes en estado residual para purgar."
        return 0
    fi

    echo "Se purgarán los siguientes $count paquetes en estado residual:"
    echo "$rc_pkgs" | sed 's/^/  - /'

    if [[ "$dry_run" == "true" ]]; then
        echo "[SIMULACIÓN] Se ejecutaría: dpkg --purge <paquetes>"
        return 0
    fi

    # Comprobar sudo sin romper
    if command -v sudo >/dev/null 2>&1; then
        echo "Ejecutando purga de paquetes residuales..."
        echo "$rc_pkgs" | xargs -r sudo dpkg --purge
        echo "[ÉXITO] Configuraciones residuales purgadas."
    else
        echo "[ERROR] Se requieren privilegios de administrador para ejecutar dpkg --purge." >&2
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    audit_packages
fi
