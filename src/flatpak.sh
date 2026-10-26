#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — DIAGNÓSTICO Y LIMPIEZA DE FLATPAK (src/flatpak.sh)
# ==============================================================================

set -Eeuo pipefail

audit_flatpak() {
    echo "=== DIAGNÓSTICO DE FLATPAK ==="
    if ! command -v flatpak >/dev/null 2>&1; then
        echo "Flatpak no está instalado en este sistema."
        return 0
    fi

    echo "--- Aplicaciones Instaladas ---"
    flatpak list --app --columns=name,application,size 2>/dev/null || echo "No se pudieron listar aplicaciones."
    
    echo ""
    echo "--- Runtimes / Extensiones no utilizadas ---"
    local unused
    unused=$(flatpak list --unused --columns=name,application,branch,size 2>/dev/null || true)
    if [[ -n "$unused" ]]; then
        echo "$unused"
        echo "Se encontraron runtimes huérfanos que pueden ser retirados sin afectar aplicaciones activas."
    else
        echo "No se encontraron runtimes o extensiones Flatpak huérfanas."
    fi
}

clean_unused_flatpak() {
    local dry_run="${1:-false}"
    if ! command -v flatpak >/dev/null 2>&1; then
        return 0
    fi

    if [[ "$dry_run" == "true" ]]; then
        echo "[SIMULACIÓN] Se ejecutaría: flatpak uninstall --unused -y"
        return 0
    fi

    echo "Desinstalando runtimes no utilizados de Flatpak..."
    flatpak uninstall --unused -y 2>/dev/null || true
    echo "[ÉXITO] Runtimes huérfanos de Flatpak eliminados."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    audit_flatpak
fi
