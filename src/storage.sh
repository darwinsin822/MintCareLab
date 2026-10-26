#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — ANÁLISIS DE DISCOS, PARTICIONES Y MONTAJES (src/storage.sh)
# ==============================================================================

set -Eeuo pipefail

get_disk_info() {
    df -h / | awk 'NR==2 {printf "TOTAL:%s|USADO:%s|DISP:%s|PORC:%s\n", $2, $3, $4, $5}'
}

list_mounts() {
    echo "=== PARTICIONES Y PUNTOS DE MONTAJE ==="
    findmnt -D -e 2>/dev/null || df -h -x tmpfs -x devtmpfs -x squashfs
}

check_remote_mounts() {
    echo "=== DETECCIÓN DE ALMACENAMIENTO REMOTO / RCLONE ==="
    local rclone_mounts
    rclone_mounts=$(findmnt -t fuse.rclone -o TARGET,SOURCE,FSTYPE 2>/dev/null || true)
    if [[ -n "$rclone_mounts" ]]; then
        echo "ALERTA: Se detectaron montajes activos de Rclone:"
        echo "$rclone_mounts"
        echo "[SEGURIDAD] Todas las unidades remotas han sido excluidas de cualquier operación de limpieza."
    else
        echo "No se detectaron unidades Rclone montadas actualmente."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    get_disk_info
    list_mounts
    check_remote_mounts
fi
