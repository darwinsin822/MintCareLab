#!/usr/bin/env bash
# ==============================================================================
# MINTCARE LAB — SCRIPT DE PURGA TOTAL DE SPOTIFY Y SPICETIFY
# ==============================================================================

set -Eeuo pipefail

echo "=========================================================="
echo "  🛡️ MINTCARE LAB — ELIMINACIÓN TOTAL DE SPOTIFY & SPICETIFY"
echo "=========================================================="

echo "[1/4] Desinstalando paquete spotify-client de APT..."
sudo apt-get purge -y spotify-client

echo "[2/4] Limpiando dependencias residuales..."
sudo apt-get autoremove -y

echo "[3/4] Eliminando repositorio y clave GPG de Spotify..."
sudo rm -f /etc/apt/sources.list.d/spotify.list
sudo rm -f /etc/apt/trusted.gpg.d/spotify.gpg
sudo rm -f /usr/share/applications/spotify.desktop
sudo rm -rf /usr/share/spotify

echo "[4/4] Limpiando posibles residuos en el usuario..."
rm -rf "$HOME/.var/app/com.spotify.Client" \
       "$HOME/.config/spotify" \
       "$HOME/.cache/spotify" \
       "$HOME/.spicetify" \
       "$HOME/.config/spicetify" \
       "$HOME/.local/share/spotify" \
       "$HOME/.local/share/applications/spotify*.desktop"

sed -i '/spicetify/d' "$HOME/.bashrc" || true

echo ""
echo "=========================================================="
echo "✓ SPOTIFY Y SPICETIFY HAN SIDO PURGADOS AL 100% DE TU SISTEMA."
echo "=========================================================="
