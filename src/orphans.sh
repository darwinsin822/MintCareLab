#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — DETECCIÓN DE RESIDUOS Y LANZADORES HUÉRFANOS (src/orphans.sh)
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SEC="${SCRIPT_DIR}/security.py"

find_orphan_launchers() {
    echo "=== ESCANEO DE LANZADORES .DESKTOP EN ~/.local/share/applications ==="
    local app_dir="$HOME/.local/share/applications"
    if [[ ! -d "$app_dir" ]]; then
        echo "No existe $app_dir."
        return 0
    fi

    local found=0
    for f in "$app_dir"/*.desktop; do
        [[ -f "$f" ]] || continue
        # Extraer el comando Exec
        local exec_line
        exec_line=$(grep -E "^Exec=" "$f" | head -n 1 | cut -d= -f2- || true)
        local cmd
        cmd=$(echo "$exec_line" | awk '{print $1}')
        # Quitar comillas si las hay
        cmd="${cmd%\"}"
        cmd="${cmd#\"}"

        # Evitar verificar ONLYOFFICE (siempre protegido)
        if [[ "$f" =~ onlyoffice ]]; then
            continue
        fi

        # Si el comando es una ruta absoluta y no existe
        if [[ "$cmd" =~ ^/ && ! -e "$cmd" ]]; then
            echo "[HUÉRFANO DETECTADO] Lanzador: $f -> Comando inexistente: $cmd"
            found=1
        elif [[ ! "$cmd" =~ ^/ && -n "$cmd" ]]; then
            if ! command -v "$cmd" >/dev/null 2>&1; then
                # Verificar si es comando flatpak o wine
                if [[ ! "$cmd" =~ ^(flatpak|wine) ]]; then
                    echo "[POSIBLE HUÉRFANO] Lanzador: $f -> Comando no encontrado en PATH: $cmd"
                    found=1
                fi
            fi
        fi
    done

    if [[ "$found" -eq 0 ]]; then
        echo "No se encontraron lanzadores huérfanos evidentes."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    find_orphan_launchers
fi
