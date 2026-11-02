#!/usr/bin/env python3
"""
MINTCARE LAB — MOTOR DE SEGURIDAD Y PROTECCIÓN TÉCNICA (src/security.py)
Regla Suprema: Protección técnica estricta y absoluta de Documentos, Música y datos críticos.
"""

import os
import sys
import shutil
from pathlib import Path

MINTCARE_ROOT = Path(__file__).resolve().parent.parent
PROTECTED_CONF = MINTCARE_ROOT / "config" / "protected-paths.conf"

SYSTEM_CRITICAL_DIRECTORIES = {
    "/", "/boot", "/etc", "/sys", "/proc", "/dev", "/lib", "/lib64",
    "/usr", "/bin", "/sbin", "/root", str(Path.home())
}

_CACHED_PROTECTED_PATHS = None

def load_protected_paths():
    global _CACHED_PROTECTED_PATHS
    if _CACHED_PROTECTED_PATHS is not None:
        return _CACHED_PROTECTED_PATHS

    paths = set()
    if PROTECTED_CONF.exists():
        with open(PROTECTED_CONF, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                clean_path = line.split("#")[0].strip()
                if clean_path:
                    p = Path(clean_path).expanduser()
                    paths.add(str(p.resolve()))
    else:
        home = Path.home()
        paths.update([
            str((home / "Documentos").resolve()),
            str((home / "Documents").resolve()),
            str((home / "Música").resolve()),
            str((home / "Music").resolve()),
            str((home / "Drive").resolve())
        ])
    _CACHED_PROTECTED_PATHS = sorted(list(paths))
    return _CACHED_PROTECTED_PATHS


def is_path_protected(target_path: str) -> bool:
    if not target_path or not str(target_path).strip():
        return True # Proteger ante vacío
    
    t = Path(target_path).expanduser()
    try:
        real_target = str(t.resolve())
    except Exception:
        real_target = str(t.absolute())

    # 1. Prohibir si la ruta es EXACTAMENTE una ruta crítica del sistema o el HOME entero
    if real_target in SYSTEM_CRITICAL_DIRECTORIES:
        return True

    # 2. Verificar contra rutas protegidas (Documentos, Música, Drive, etc.)
    # Aquí sí se prohíbe tanto la carpeta exacta como cualquier subdirectorio / archivo dentro
    protected_list = load_protected_paths()
    for prot in protected_list:
        if prot in SYSTEM_CRITICAL_DIRECTORIES:
            # Para raíces del sistema solo aplica match exacto para no bloquear todo el disco
            if real_target == prot:
                return True
        else:
            # Para carpetas del usuario protegidas (Documentos, Música, Drive, OnlyOffice, etc.)
            # se protege la carpeta exacta Y todo lo que esté anidado dentro
            if real_target == prot or real_target.startswith(prot.rstrip("/") + "/"):
                return True

    return False

def safe_delete(target_path: str, dry_run: bool = False) -> int:
    """
    Retorna:
      0: Éxito
      1: No existe
      2: BLOQUEADO POR PROTECCIÓN
      3: Error de I/O
    """
    if is_path_protected(target_path):
        sys.stderr.write(f"[BLOQUEO DE SEGURIDAD] ACCESO DENEGADO: La ruta '{target_path}' está protegida por la Regla Suprema.\n")
        return 2

    p = Path(target_path).expanduser()
    if not p.exists() and not p.is_symlink():
        sys.stdout.write(f"[AVISO] La ruta '{target_path}' no existe.\n")
        return 1

    if dry_run:
        sys.stdout.write(f"[SIMULACIÓN] Se eliminaría de forma segura: {target_path}\n")
        return 0

    try:
        if p.is_symlink() or p.is_file():
            p.unlink()
        elif p.is_dir():
            shutil.rmtree(p)
        sys.stdout.write(f"[LIMPIEZA REALIZADA] Eliminado con éxito: {target_path}\n")
        return 0
    except Exception as e:
        sys.stderr.write(f"[ERROR] Error al eliminar '{target_path}': {e}\n")
        return 3

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: security.py <check|delete|dry-delete> <ruta>")
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "check":
        target = sys.argv[2]
        if is_path_protected(target):
            print(f"PROTEGIDO: {target}")
            sys.exit(0)
        else:
            print(f"LIBRE: {target}")
            sys.exit(1)
    elif cmd == "delete":
        target = sys.argv[2]
        sys.exit(safe_delete(target, dry_run=False))
    elif cmd == "dry-delete":
        target = sys.argv[2]
        sys.exit(safe_delete(target, dry_run=True))
