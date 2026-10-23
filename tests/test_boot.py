"""The computer retains its proxy configuration through foreground startup."""

import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest import TestCase


class BootTest(TestCase):
    def test_proxy_login_and_headless_serving_tolerate_missing_google(self) -> None:
        for uid, home in ((0, "/root"), (10000, "/home/latch")):
            with self.subTest(uid=uid), TemporaryDirectory() as directory:
                root = Path(directory)
                for name, body in {
                    "id": '#!/bin/sh\nprintf "%s\\n" "$SIMULATED_UID"\n',
                    "setpriv": '''#!/bin/sh
set -eu
[ "$1" = --reuid=latch ] && [ "$2" = --regid=latch ] && [ "$3" = --init-groups ]
shift 3
exec env SIMULATED_UID=10000 "$@"
''',
                    "latch": '''#!/bin/sh
set -eu
[ "$SIMULATED_UID" = 10000 ]
[ "$HOME" = /home/latch ]
[ "$PLOW_API_BASE" = https://boot-smoke.invalid ]
[ -z "${PLOW_AGENT_TOKEN:-}" ]
case "$1" in
    login)
        [ "$2" = --name ] && [ "$3" = cloud ] && [ "$4" = --token-file ]
        [ "$(cat "$5")" = proxied ]
        printf 'logged in through proxy\\n'
        ;;
    plugins) exit 1 ;;
    serve)
        [ "$2" = --foreground ] && [ "$3" = --headless-browsers ]
        printf 'serving as latch with proxy\\n'
        printf 'serving with proxy: %s\\n' "$PLOW_API_BASE"
        ;;
esac
''',
                }.items():
                    program = root / name
                    program.write_text(body)
                    program.chmod(0o755)
                boot = root / "boot.sh"
                boot.write_bytes((Path(__file__).resolve().parents[1] / "cloud/boot.sh").read_bytes())
                boot.chmod(0o755)
                result = subprocess.run(
                    [str(boot)],
                    env={
                        "PATH": f"{root}:/usr/bin:/bin",
                        "HOME": home,
                        "SIMULATED_UID": str(uid),
                        "PLOW_API_BASE": "https://boot-smoke.invalid",
                    },
                    capture_output=True,
                    text=True,
                    check=False,
                    timeout=10,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("logged in through proxy", result.stdout)
                self.assertIn("serving with proxy: https://boot-smoke.invalid", result.stdout)
                self.assertIn("serving as latch with proxy", result.stdout)
