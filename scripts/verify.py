"""Offline syntax and pinned metadata checks; not native installation acceptance."""
import re
import subprocess
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]


def validate(text):
    errors = []
    values = {}
    for field in ('version', 'sha256', 'url'):
        matches = re.findall(r'^\s*' + field + r'\s+"([^"\n]+)"\s*$', text, re.M)
        if len(matches) != 1:
            errors.append(f'{field}: expected one literal value')
        else:
            values[field] = matches[0]
    if not re.search(r'^cask "axloop-community" do$', text, re.M):
        errors.append('Unexpected cask identity')
    if 'sha256' in values and not re.fullmatch(r'[0-9a-f]{64}', values['sha256']):
        errors.append('Expected a pinned SHA-256 digest')
    if 'url' in values:
        url = urlsplit(values['url'])
        if url.scheme != 'https' or url.netloc != 'github.com' or url.query or url.fragment:
            errors.append('Expected a direct HTTPS GitHub release URL')
        if 'version' in values:
            prefix = '/axloop/axloop-community/releases/download/v' + values['version'] + '/'
            if not url.path.startswith(prefix) or not url.path.endswith('.tar.gz'):
                errors.append('Release URL does not match the pinned version/archive')
    binaries = re.findall(r'^\s*binary "([^"\n]+)"\s*$', text, re.M)
    if not binaries or any(x not in ('bin/axloop-community', 'bin/axloop-crawler') for x in binaries):
        errors.append('Expected a supported Community command asset')
    return errors


def main():
    cask = ROOT / 'Casks/axloop-community.rb'
    syntax = subprocess.run(['ruby', '-c', str(cask)], check=False)
    errors = validate(cask.read_text())
    for error in errors:
        print(error)
    passed = syntax.returncode == 0 and not errors
    print('Cask metadata: ' + ('PASS' if passed else 'FAIL'))
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
