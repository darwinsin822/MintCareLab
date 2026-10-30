#!/usr/bin/env bash
set -euo pipefail
echo "🧪 [1/2] Verificando sintaxis de scripts Bash..."
bash -n mintcare.sh
for s in src/*.sh; do
  [ -f "$s" ] && bash -n "$s"
done
echo "✔ Sintaxis de scripts correcta."

echo "🧪 [2/2] Ejecutando suite de seguridad y blindaje de datos..."
python3 tests/test_security_py.py
echo "✅ Todas las pruebas de MintCareLab pasaron al 100%."
