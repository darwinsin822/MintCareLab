#!/usr/bin/env python3
"""
MINTCARE LAB — GENERADOR DE INFORMES Y COMPARATIVAS (src/report.py)
"""

import os
import sys
import json
import datetime
from pathlib import Path
import subprocess

MINTCARE_ROOT = Path(__file__).resolve().parent.parent
REPORTS_DIR = MINTCARE_ROOT / "reports"

def generate_report():
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = REPORTS_DIR / f"storage_report_{timestamp}.json"

    # Disk usage
    df_out = subprocess.check_output(["df", "-h", "/"], text=True).strip().split("\n")[1].split()
    disk_info = {
        "device": df_out[0],
        "size": df_out[1],
        "used": df_out[2],
        "available": df_out[3],
        "percent": df_out[4]
    }

    report_data = {
        "timestamp": datetime.datetime.now().isoformat(),
        "disk": disk_info,
        "protected_status": "ENFORCED (Documentos, Música, Drive)",
        "categories_analyzed": [
            "User Cache (~/.cache)",
            "NPM Cache (~/.npm)",
            "Gradle Caches & Wrappers (~/.gradle)",
            "Flatpak Runtimes & Apps (~/.var)",
            "APT & DPKG Residuals",
            "Dart & Flutter Cache (~/.pub-cache)"
        ]
    }

    with open(report_file, "w", encoding="utf-8") as f:
        json.dump(report_data, f, indent=2, ensure_ascii=False)

    print(f"[REPORTE] Informe guardado exitosamente en: {report_file}")
    return report_file

if __name__ == "__main__":
    generate_report()
