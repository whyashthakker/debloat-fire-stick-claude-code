"""firehome/install.sh passes FIREHOME_APPS to the TV, and only bare package names.

Run from the repository root: python3 -m unittest discover -s tests -v
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class FirehomeInstallTest(unittest.TestCase):
    def run_install(self, apps=None):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp) / "repo"
            (repo / "firehome").mkdir(parents=True)
            shutil.copy2(ROOT / "firehome" / "install.sh", repo / "firehome" / "install.sh")
            built = Path(tmp) / "built"
            build = repo / "firehome" / "build.sh"
            build.write_text(f'#!/bin/sh\ntouch "{built.as_posix()}"\n')
            build.chmod(0o755)
            # Fake tv.py client: records --batch input, ignores --push.
            client = repo / "tools" / "venv" / "bin" / "python"
            client.parent.mkdir(parents=True)
            client.write_text('#!/bin/sh\ncase "$*" in *--batch*) cat > "$CAPTURE" ;; esac\n')
            client.chmod(0o755)
            capture = Path(tmp) / "commands.txt"
            env = dict(os.environ, CAPTURE=str(capture))
            env.pop("FIREHOME_APPS", None)
            if apps is not None:
                env["FIREHOME_APPS"] = apps
            result = subprocess.run(["bash", str(repo / "firehome" / "install.sh")], cwd=repo,
                                    env=env, capture_output=True, text=True)
            commands = capture.read_text().splitlines() if capture.exists() else []
            return result, commands, built.exists()

    def test_youtube_by_default(self):
        result, commands, _ = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(commands[-1], "am start -n com.firehome/.HomeActivity --es apps com.amazon.firetv.youtube")

    def test_apps_in_order(self):
        result, commands, _ = self.run_install("com.global.unitviptv  com.amazon.firetv.youtube com.spotify.tv.android")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(commands[-1].endswith(
            "--es apps com.global.unitviptv,com.amazon.firetv.youtube,com.spotify.tv.android"))

    def test_refuses_shell_syntax_before_touching_the_tv(self):
        result, commands, built = self.run_install("com.amazon.firetv.youtube x;reboot")
        self.assertEqual(result.returncode, 1)
        self.assertIn("not a package name", result.stderr)
        self.assertEqual(commands, [])
        self.assertFalse(built)


if __name__ == "__main__":
    unittest.main()
