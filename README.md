# 🛡️ MintCare Lab — Laboratorio Inteligente de Mantenimiento para Linux Mint Cinnamon

**MintCare Lab** es una suite local de mantenimiento, diagnóstico preventivo y auditoría de almacenamiento diseñada a medida para Linux Mint Cinnamon.

Su misión primordial es mantener el sistema rápido, ordenado y con espacio libre sin riesgo de eliminar datos vitales, proyectos personales ni herramientas indispensables.

---

## 🔒 REGLA SUPREMA: PROTECCIÓN TÉCNICA INVIOLABLE

Las siguientes ubicaciones están **estrictamente protegidas a nivel del motor de ejecución (`src/security.py`)**:
- `~/Documentos/` (y `~/Documents/`)
- `~/Música/` (y `~/Music/`)
- `~/Drive` (Montajes remotos Rclone)
- Editor de documentos **ONLYOFFICE** (`~/.config/onlyoffice`, `/usr/bin/onlyoffice-desktopeditors`)
- Directorio de proyectos Antigravity (`~/.gemini/antigravity/scratch/`)
- Credenciales y llaves (`~/.ssh`, `~/.gnupg`)

> **Criterio de Aceptación:** Ninguna función, script o comando de MintCare Lab puede modificar, mover o eliminar contenido de estas carpetas bajo ninguna circunstancia o parámetro. El motor de seguridad interrumpe la operación arrojando código de salida `2` (Acceso Denegado).

---

## 📂 Arquitectura del Proyecto

```text
~/MintCareLab/
├── mintcare.sh               # Interfaz principal de terminal interactiva
├── config/
│   ├── protected-paths.conf # Lista de rutas estrictamente protegidas
│   └── cleanup-policy.conf  # Políticas de cuotas y confirmación
├── src/
│   ├── security.py          # Motor central de validación de rutas y borrado seguro
│   ├── audit.sh             # Diagnóstico general de solo lectura
│   ├── cleaners.sh          # Rutinas de limpieza acotadas (CLEAN-001 a CLEAN-006)
│   ├── development.sh       # Inspección de NPM, Gradle, Android SDK, Flutter, Rust
│   ├── flatpak.sh           # Detección de runtimes y extensiones huérfanas
│   ├── packages.sh          # Análisis de paquetes residuales (rc) y APT
│   ├── storage.sh           # Análisis de discos y montajes Rclone
│   ├── orphans.sh           # Detección de lanzadores .desktop huérfanos
│   └── report.py            # Generación de informes en JSON
├── tests/
│   └── test_security_py.py  # Suite de pruebas automatizadas de seguridad
├── reports/                 # Informes generados
└── logs/                    # Historial de operaciones
```

---

## 🚀 Modos de Operación

Ejecuta el script principal desde la terminal:

```bash
cd ~/MintCareLab
./mintcare.sh [MODO]
```

### Modos Disponibles:

1. **`./mintcare.sh audit`**:
   - Modo de solo lectura por defecto. Diagnostica disco, cachés, paquetes y herramientas sin tocar nada.
2. **`./mintcare.sh plan`**:
   - Muestra el listado priorizado de acciones seguras recomendadas (`CLEAN-001` a `CLEAN-006`) con el espacio recuperable estimado.
3. **`./mintcare.sh clean-safe`**:
   - Ejecuta las limpiezas 100% regenerables y seguras (previa confirmación por teclado).
4. **`./mintcare.sh interactive`**:
   - Pregunta paso a paso antes de limpiar cada categoría específica.
5. **`./mintcare.sh verify`**:
   - Comprueba el estado del disco y valida que las rutas protegidas continúen blindadas.
6. **`./mintcare.sh report`**:
   - Produce un informe estructurado JSON en `reports/`.
7. **`./mintcare.sh test-sec`**:
   - Ejecuta la batería de pruebas de seguridad para certificar que el blindaje de la Regla Suprema está activo.

---

## 🧪 Pruebas de Seguridad Automatizadas

Para validar que la protección técnica bloquee cualquier intento destructivo sobre carpetas personales, symlinks o montajes remotos:

```bash
python3 ~/MintCareLab/tests/test_security_py.py
```
*(Resultado certificado: 7/7 pruebas aprobadas con éxito).*
