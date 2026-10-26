#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — MOTOR DE AUDITORÍA GENERAL (src/audit.sh)
# ==============================================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_full_audit() {
    echo "=================================================================="
    echo "   🛡️  MINTCARE LAB — AUDITORÍA GENERAL DE ALMACENAMIENTO        "
    echo "=================================================================="
    
    source "${SCRIPT_DIR}/storage.sh"
    echo ""
    get_disk_info
    echo ""
    check_remote_mounts
    echo ""
    
    source "${SCRIPT_DIR}/development.sh"
    audit_dev_tools
    echo ""

    source "${SCRIPT_DIR}/flatpak.sh"
    audit_flatpak
    echo ""

    source "${SCRIPT_DIR}/packages.sh"
    audit_packages
    echo ""

    source "${SCRIPT_DIR}/orphans.sh"
    find_orphan_launchers
    echo ""
    
    echo "=================================================================="
    echo "Auditoría completada sin modificar ningún archivo (Solo Lectura)."
    echo "=================================================================="
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_full_audit
fi
