#!/usr/bin/env python3
import sys
import unittest
from pathlib import Path
import tempfile
import os

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "src"))
from security import is_path_protected, safe_delete

class TestMintCareSecurity(unittest.TestCase):
    def setUp(self):
        self.home = Path.home()

    def test_documentos_and_musica_protected(self):
        self.assertTrue(is_path_protected(str(self.home / "Documentos")))
        self.assertTrue(is_path_protected(str(self.home / "Documentos" / "tesis.docx")))
        self.assertTrue(is_path_protected(str(self.home / "Documentos" / "sub" / "archivo.pdf")))
        self.assertTrue(is_path_protected(str(self.home / "Música")))
        self.assertTrue(is_path_protected(str(self.home / "Música" / "Rock" / "song.flac")))

    def test_drive_and_rclone_protected(self):
        self.assertTrue(is_path_protected(str(self.home / "Drive")))
        self.assertTrue(is_path_protected(str(self.home / "Drive" / "fotos")))

    def test_onlyoffice_protected(self):
        self.assertTrue(is_path_protected("/usr/bin/onlyoffice-desktopeditors"))
        self.assertTrue(is_path_protected(str(self.home / ".config" / "onlyoffice")))
        self.assertTrue(is_path_protected(str(self.home / ".var" / "app" / "org.onlyoffice.desktopeditors")))

    def test_system_roots_protected(self):
        self.assertTrue(is_path_protected("/"))
        self.assertTrue(is_path_protected(str(self.home)))
        self.assertTrue(is_path_protected("/etc"))

    def test_symlinks_to_protected_paths(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            symlink_docs = Path(tmpdir) / "fake_docs"
            os.symlink(str(self.home / "Documentos"), str(symlink_docs))
            self.assertTrue(is_path_protected(str(symlink_docs)))
            self.assertTrue(is_path_protected(str(symlink_docs / "algo.txt")))

            symlink_music = Path(tmpdir) / "fake_music"
            os.symlink(str(self.home / "Música"), str(symlink_music))
            self.assertTrue(is_path_protected(str(symlink_music)))

    def test_safe_delete_blocks_protected(self):
        res_doc = safe_delete(str(self.home / "Documentos" / "test_fake.pdf"), dry_run=False)
        self.assertEqual(res_doc, 2)
        res_music = safe_delete(str(self.home / "Música" / "test_fake.mp3"), dry_run=False)
        self.assertEqual(res_music, 2)

    def test_disposable_cache_is_free(self):
        self.assertFalse(is_path_protected(str(self.home / ".cache" / "google-chrome" / "Default" / "Cache")))
        self.assertFalse(is_path_protected(str(self.home / ".npm" / "_cacache")))

if __name__ == "__main__":
    unittest.main()
