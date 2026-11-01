#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — SCRIPT DE PURGA TOTAL DE CHATGPT / CODEX (scripts/purge_chatgpt.sh)
# ==============================================================================

set -Eeuo pipefail

echo "=========================================================="
echo "  🛡️ MINTCARE LAB — ELIMINACIÓN TOTAL DE CHATGPT / CODEX"
echo "=========================================================="

echo "[1/3] Desinstalando paquete chatgpt de APT/dpkg..."
sudo apt-get purge -y chatgpt || sudo dpkg --purge chatgpt

echo "[2/3] Limpiando dependencias residuales..."
sudo apt-get autoremove -y

echo "[3/3] Eliminando lanzadores y entradas de escritorio..."
sudo rm -f /usr/share/applications/chatgpt.desktop
rm -f "$HOME/.local/share/applications/chatgpt.desktop"

echo ""
echo "=========================================================="
echo "✓ CHATGPT / CODEX HA SIDO PURGADO AL 100% DE TU SISTEMA."
echo "=========================================================="
