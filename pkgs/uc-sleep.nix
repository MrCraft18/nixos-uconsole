{
  lib,
  python3,
  fetchFromGitHub,
  ...
}:
let
  pname = "uc-sleep";
  date = "20251215";
  rev = "fb97421766eea93f55ac31d1865c47e0913cee70";
  hash = "sha256-zJzKKENLPsgun7zGSpNLy6LPcdO55F/XeLDbAxxZpD0=";
  propagatedBuildInputs = with python3.pkgs; [
    python-uinput
    inotify-simple
  ];
in
python3.pkgs.buildPythonApplication {
  inherit pname propagatedBuildInputs;

  version = "unstable-${date}";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "robertjakub";
    repo = "uConsole-sleep";
    inherit rev hash;
  };
  build-system = with python3.pkgs; [ setuptools];

  preBuild = ''
    touch src/__init__.py
    cat >> src/sleep_power_control.py << EOF
def main():
  pass

EOF
    cat >> src/sleep_remap_powerkey.py << EOF
def main():
  pass

EOF
    cat > pyproject.toml << EOF
[project]
name = "${pname}"
version = "0.0.0.dev${date}+git.${builtins.substring 0 7 rev}"
dependencies = [
${lib.concatMapStringsSep "\n" (d: "  \"${d.pname}\",") propagatedBuildInputs}
]

[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[project.scripts]
sleep_power_control = "sleep_power_control:main"
sleep_remap_powerkey = "sleep_remap_powerkey:main"
EOF
  '';

  meta = {
    description = "uConsole power button sleep/wake handling";
    homepage = "https://github.com/robertjakub/uConsole-sleep";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
