#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — TEST SUITE DE SEGURIDAD (tests/test_security.sh)
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../src/security.sh"

echo "=== INICIANDO PRUEBAS DE SEGURIDAD Y REGLA SUPREMA ==="

PASSED=0
FAILED=0

run_check() {
    local target="$1"
    local desc="$2"
    local expect_protected="$3"

    local is_prot=0
    if is_path_protected "$target"; then
        is_prot=1
    fi

    if [[ "$is_prot" -eq "$expect_protected" ]]; then
        echo "  [PASS] $desc: '$target' -> OK"
        PASSED=$((PASSED + 1))
    else
        echo "  [FAIL] $desc: '$target' -> ESPERADO $expect_protected, OBTENIDO $is_prot" >&2
        FAILED=$((FAILED + 1))
    fi
}

# 1. Carpetas intocables (Regla Suprema)
run_check "$HOME/Documentos" "Directorio Documentos directo" 1
run_check "$HOME/Documentos/subcarpeta/archivo.pdf" "Archivo anidado en Documentos" 1
run_check "$HOME/Música" "Directorio Música directo" 1
run_check "$HOME/Música/Artista/Album/cancion.flac" "Canción anidada en Música" 1

# 2. Symlinks
TMP_SYMLINK_DOCS="/tmp/mintcare_test_symlink_docs"
ln -sfn "$HOME/Documentos" "$TMP_SYMLINK_DOCS"
run_check "$TMP_SYMLINK_DOCS" "Enlace simbólico a Documentos" 1
run_check "$TMP_SYMLINK_DOCS/test.txt" "Subruta via symlink a Documentos" 1
rm -f "$TMP_SYMLINK_DOCS"

TMP_SYMLINK_MUSIC="/tmp/mintcare_test_symlink_music"
ln -sfn "$HOME/Música" "$TMP_SYMLINK_MUSIC"
run_check "$TMP_SYMLINK_MUSIC" "Enlace simbólico a Música" 1
rm -f "$TMP_SYMLINK_MUSIC"

# 3. Montajes Rclone y Almacenamiento Remoto
run_check "$HOME/Drive" "Montaje Rclone Drive" 1
run_check "$HOME/Drive/Backup" "Subdirectorio dentro de Drive" 1

# 4. ONLYOFFICE y Configuración
run_check "/usr/bin/onlyoffice-desktopeditors" "Binario ONLYOFFICE" 1
run_check "$HOME/.config/onlyoffice" "Configuración ONLYOFFICE" 1
run_check "$HOME/.var/app/org.onlyoffice.desktopeditors" "Flatpak ONLYOFFICE" 1

# 5. Sistema y Home
run_check "/" "Raíz del sistema" 1
run_check "$HOME" "Home completo del usuario" 1

# 6. Intentos de borrado destructivo
echo "=== PROBANDO INTENTOS DE BORRADO BLOQUEADOS ==="
set +e
safe_delete_path "$HOME/Documentos/archivo_falso.txt" 2>/dev/null
res_docs=$?
safe_delete_path "$HOME/Música/cancion_falsa.mp3" 2>/dev/null
res_music=$?
set -e

if [[ $res_docs -eq 2 ]]; then
    echo "  [PASS] safe_delete_path bloqueó intento en Documentos con código de denegación 2."
    PASSED=$((PASSED + 1))
else
    echo "  [FAIL] safe_delete_path NO BLOQUEÓ intento en Documentos!" >&2
    FAILED=$((FAILED + 1))
fi

if [[ $res_music -eq 2 ]]; then
    echo "  [PASS] safe_delete_path bloqueó intento en Música con código de denegación 2."
    PASSED=$((PASSED + 1))
else
    echo "  [FAIL] safe_delete_path NO BLOQUEÓ intento en Música!" >&2
    FAILED=$((FAILED + 1))
fi

# 7. Rutas no protegidas
run_check "$HOME/.cache/google-chrome/Default/Cache" "Caché de navegador desechable" 0

echo "====================================================="
echo "RESULTADO FINAL: $PASSED pruebas pasadas, $FAILED fallidas."
if [[ $FAILED -eq 0 ]]; then
    echo "ESTADO: VERIFICACIÓN DE REGLA SUPREMA EXITOSA (100% BLINDADA)."
    exit 0
else
    echo "ESTADO: FALLO EN SEGURIDAD."
    exit 1
fi
