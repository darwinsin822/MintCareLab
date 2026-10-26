#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — MOTOR DE SEGURIDAD Y PROTECCIÓN TÉCNICA (src/security.sh)
# ==============================================================================
# REGLA SUPREMA: Protección técnica obligatoria e ineludible de Documentos,
# Música, almacenamiento montado y archivos protegidos del sistema.
# ==============================================================================

MINTCARE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTECTED_CONF="${MINTCARE_ROOT}/config/protected-paths.conf"

# Cargar lista de rutas protegidas
get_protected_paths() {
    local paths=()
    if [[ -f "$PROTECTED_CONF" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Ignorar comentarios y líneas vacías
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue
            paths+=("${line%%#*}")
        done < "$PROTECTED_CONF"
    else
        paths=(
            "$HOME/Documentos"
            "$HOME/Documents"
            "$HOME/Música"
            "$HOME/Music"
            "$HOME/Drive"
            "/"
        )
    fi
    printf '%s\n' "${paths[@]}"
}

# Comprobar si una ruta está protegida
# Retorna 0 (protegida -> PROHIBIDO TOCAR) o 1 (no protegida)
is_path_protected() {
    local target="$1"
    
    if [[ -z "${target// }" ]]; then
        echo "[SEGURIDAD ALERTA] Intento de validar ruta vacía." >&2
        return 0
    fi

    # Resolver la ruta canónica absoluta
    local real_target=""
    if [[ -e "$target" || -L "$target" ]]; then
        real_target=$(realpath -q -m "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || echo "$target")
    else
        real_target=$(realpath -q -m "$target" 2>/dev/null || echo "$target")
    fi

    # Raíz y Home directo
    if [[ "$real_target" == "/" || "$real_target" == "$HOME" ]]; then
        return 0
    fi

    # Verificar contra cada ruta protegida
    while IFS= read -r prot_path; do
        [[ -z "${prot_path// }" ]] && continue
        local real_prot=""
        real_prot=$(realpath -q -m "$prot_path" 2>/dev/null || echo "$prot_path")

        # Prohibir si es exactamente la raíz / ruta protegida o está dentro
        if [[ "$real_target" == "$real_prot" || "$real_target" == "$real_prot"/* ]]; then
            return 0
        fi
    done < <(get_protected_paths)

    return 1
}

safe_delete_path() {
    local target="$1"
    local dry_run="${2:-false}"

    if is_path_protected "$target"; then
        echo "[BLOQUEO DE SEGURIDAD] ACCESO DENEGADO: La ruta '$target' está protegida por la Regla Suprema." >&2
        return 2
    fi

    if [[ "$dry_run" == "true" ]]; then
        echo "[SIMULACIÓN] Se eliminaría de forma segura: $target"
        return 0
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        rm -rf -- "$target"
        echo "[LIMPIEZA REALIZADA] Eliminado con éxito: $target"
        return 0
    else
        echo "[AVISO] La ruta '$target' no existe."
        return 1
    fi
}
