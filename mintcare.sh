#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — INTERFAZ PRINCIPAL DE TERMINAL (mintcare.sh)
# ==============================================================================
# Laboratorio Inteligente de Mantenimiento para Linux Mint Cinnamon
# REGLA SUPREMA: Protección absoluta de Documentos y Música (Blindaje Técnico).
# ==============================================================================

set -Eeuo pipefail

MINTCARE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export MINTCARE_DIR

# Colores si el terminal lo soporta
if [[ -t 1 ]]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_RED="\033[31m"
    C_CYAN="\033[36m"
    C_BLUE="\033[34m"
else
    C_RESET=""
    C_BOLD=""
    C_GREEN=""
    C_YELLOW=""
    C_RED=""
    C_CYAN=""
    C_BLUE=""
fi

show_banner() {
    echo -e "${C_CYAN}${C_BOLD}"
    echo "======================================================================"
    echo "  🛡️  MINTCARE LAB — MANTENIMIENTO INTELIGENTE PARA LINUX MINT       "
    echo "======================================================================"
    echo -e "${C_RESET}"
}

show_help() {
    show_banner
    echo -e "${C_BOLD}USO:${C_RESET} ./mintcare.sh [MODO]"
    echo ""
    echo -e "${C_BOLD}MODOS DE OPERACIÓN:${C_RESET}"
    echo -e "  ${C_GREEN}audit${C_RESET}       Diagnóstico completo del sistema en modo SOLO LECTURA."
    echo -e "  ${C_YELLOW}plan${C_RESET}        Prepara la lista de acciones propuestas con riesgos y GB."
    echo -e "  ${C_BLUE}clean-safe${C_RESET}  Ejecuta únicamente limpiezas seguras verificadas (Cachés)."
    echo -e "  ${C_YELLOW}interactive${C_RESET} Solicita confirmación individual antes de cada limpieza."
    echo -e "  ${C_CYAN}verify${C_RESET}      Comprueba el estado del almacenamiento y cambios."
    echo -e "  ${C_CYAN}report${C_RESET}      Genera un informe estructurado en formato JSON."
    echo -e "  ${C_RED}test-sec${C_RESET}    Ejecuta la suite de verificación de la Regla Suprema."
    echo ""
    echo -e "${C_BOLD}REGLA SUPREMA:${C_RESET} ~/Documentos y ~/Música están estrictamente blindadas."
    echo ""
}

mode_audit() {
    show_banner
    echo -e "${C_CYAN}Ejecutando auditoría de solo lectura...${C_RESET}\n"
    bash "${MINTCARE_DIR}/src/audit.sh"
}

mode_plan() {
    show_banner
    echo -e "${C_YELLOW}${C_BOLD}PLAN DE ACCIÓN PRIORIZADO (GB RECUPERABLES ESTIMADOS):${C_RESET}\n"
    cat << 'PLAN_EOF'
ID        | ACCIÓN / CATEGORÍA                  | RECUPERABLE | RIESGO
---------+-------------------------------------+-------------+---------
CLEAN-001 | Caché de Google Chrome (~/.cache)   | ~381 MB     | Muy Bajo
CLEAN-002 | Caché global de NPM (~/.npm)        | ~1.57 GB    | Muy Bajo
CLEAN-003 | Miniaturas de Cinnamon (~/.cache)   | ~2 MB       | Muy Bajo
CLEAN-004 | Temporales de Dart/Flutter          | ~244 KB     | Muy Bajo
CLEAN-005 | Temporales de Gradle (.tmp)         | ~20 MB      | Muy Bajo
CLEAN-006 | Runtimes no utilizados de Flatpak   | ~1.0 GB     | Bajo
---------+-------------------------------------+-------------+---------
TOTAL CONFIRMADO POTENCIAL LIBERABLE:          ~2.97 GB
PLAN_EOF
    echo ""
    echo -e "${C_GREEN}Para ejecutar estas acciones seguras utilice: ./mintcare.sh clean-safe${C_RESET}"
}

mode_clean_safe() {
    show_banner
    echo -e "${C_YELLOW}Se ejecutarán únicamente las limpiezas de cachés 100% regenerables.${C_RESET}"
    echo -e "${C_RED}${C_BOLD}REGLA SUPREMA: Documentos y Música NUNCA serán tocados.${C_RESET}\n"
    
    read -p "¿Desea proceder con la limpieza segura verificada? [s/N]: " confirm
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        echo "Operación cancelada por el usuario."
        exit 0
    fi

    echo ""
    source "${MINTCARE_DIR}/src/cleaners.sh"
    clean_chrome_cache false
    clean_npm false
    clean_thumbnails false
    clean_dart_temp false
    clean_gradle_temporary false
    clean_flatpak_unused false

    echo ""
    echo -e "${C_GREEN}${C_BOLD}✓ Limpieza segura finalizada con éxito.${C_RESET}"
}

mode_interactive() {
    show_banner
    echo -e "${C_YELLOW}MODO INTERACTIVO: Confirmación paso a paso.${C_RESET}\n"
    source "${MINTCARE_DIR}/src/cleaners.sh"

    local actions=(
        "clean_chrome_cache:Caché de Google Chrome (~381 MB)"
        "clean_npm:Caché global de NPM (~1.57 GB)"
        "clean_thumbnails:Miniaturas de Cinnamon (~2 MB)"
        "clean_dart_temp:Temporales de Dart/Flutter (~244 KB)"
        "clean_gradle_temporary:Temporales de Gradle (~20 MB)"
        "clean_flatpak_unused:Runtimes no utilizados de Flatpak (~1.0 GB)"
    )

    for item in "${actions[@]}"; do
        local func="${item%%:*}"
        local desc="${item##*:}"
        echo -e "${C_CYAN}Acción: $desc${C_RESET}"
        read -p "¿Desea ejecutar esta limpieza? [s/N]: " conf
        if [[ "$conf" == "s" || "$conf" == "S" ]]; then
            $func false
        else
            echo "Omitida."
        fi
        echo "--------------------------------------------------------"
    done
    echo -e "${C_GREEN}Sesión interactiva finalizada.${C_RESET}"
}

mode_verify() {
    show_banner
    echo -e "${C_CYAN}Comprobando estado del almacenamiento...${C_RESET}\n"
    source "${MINTCARE_DIR}/src/storage.sh"
    get_disk_info
    echo ""
    python3 "${MINTCARE_DIR}/src/security.py" check "$HOME/Documentos"
    python3 "${MINTCARE_DIR}/src/security.py" check "$HOME/Música"
    echo -e "\n${C_GREEN}✓ Blindaje de Documentos y Música verificado.${C_RESET}"
}

mode_report() {
    show_banner
    python3 "${MINTCARE_DIR}/src/report.py"
}

mode_test_sec() {
    show_banner
    echo -e "${C_CYAN}Ejecutando suite de pruebas de la Regla Suprema...${C_RESET}\n"
    python3 "${MINTCARE_DIR}/tests/test_security_py.py"
}

# Enrutador de comandos
MODE="${1:-audit}"

case "$MODE" in
    audit)
        mode_audit
        ;;
    plan)
        mode_plan
        ;;
    clean-safe)
        mode_clean_safe
        ;;
    interactive)
        mode_interactive
        ;;
    verify)
        mode_verify
        ;;
    report)
        mode_report
        ;;
    test-sec)
        mode_test_sec
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${C_RED}Modo no reconocido: $MODE${C_RESET}"
        show_help
        exit 1
        ;;
esac
