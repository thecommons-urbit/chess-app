#!/bin/bash
# ==============================================================================
#
# install - Install chess app files in an Urbit pier.
#
# ==============================================================================

# Stop on error
set -e

# --------------------------------------
# Functions
# --------------------------------------

#
# Print script usage
#
usage() {
  if [[ $1 -ne 0 ]]; then
    exec 1>&2
  fi

  echo -e ""
  echo -e "Usage:\t$SCRIPT_NAME [-h] [-d DESK_NAME] [-p PATH_TO_PIER] [-s SHIP_NAME] -b PATH_TO_UI_BUILD"
  echo -e ""
  echo -e "Install app files to a desk in an Urbit pier"
  echo -e "Default install location: $DEFAULT_PIER/$DEFAULT_SHIP/$DEFAULT_DESK"
  echo -e ""
  echo -e "Options:"
  echo -e "  -h\tPrint script usage info"
  echo -e "  -b\tPath to UI build directory (required)"
  echo -e "  -d\tName of desk to which to install (default: $DEFAULT_DESK)"
  echo -e "  -p\tPath to root pier directory (default: $DEFAULT_PIER)"
  echo -e "  -r\tPath to remote pier directory, access via SSH"
  echo -e "  -s\tName of ship to install to (default: $DEFAULT_SHIP)"
  echo -e ""
  exit $1
}

#
# Copy UI build files to dest, lowercasing all filenames and updating
# references in text files. Clay only allows lowercase path elements.
#
copy_ui_build() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  python3 - "$src" "$dst" <<'PYEOF'
import sys, os, shutil

src, dst = sys.argv[1], sys.argv[2]

# Collect all basename renames (old -> new)
renames = {}
for root, dirs, files in os.walk(src):
    for f in files:
        lower = f.lower()
        if f != lower:
            renames[f] = lower

# Copy tree
shutil.copytree(src, dst, dirs_exist_ok=True)

# Rename files to lowercase
for root, dirs, files in os.walk(dst):
    for f in files:
        lower = f.lower()
        if f != lower:
            os.rename(os.path.join(root, f), os.path.join(root, lower))

# Update references in text files
for root, dirs, files in os.walk(dst):
    for f in files:
        if not f.endswith(('.html', '.js', '.css')):
            continue
        path = os.path.join(root, f)
        with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
            content = fp.read()
        modified = content
        for old, new in renames.items():
            modified = modified.replace(old, new)
        if modified != content:
            with open(path, 'w', encoding='utf-8') as fp:
                fp.write(modified)
PYEOF
}

# --------------------------------------
# Variables
# --------------------------------------

INSTALL_VIA_SSH=false
SCRIPT_NAME=$(basename $0 | cut -d '.' -f 1)

SCRIPT_DIR=$(cd "$(dirname $0)" && pwd)
ROOT_DIR=$(dirname $SCRIPT_DIR)
RESOURCE_DIR="$ROOT_DIR/resources"
CHESS_DIR="$ROOT_DIR/src/chess"
DEPS_DIR="$ROOT_DIR/src/dependencies"

DEFAULT_DESK="chess"
DEFAULT_PIER="/home/$USER/Urbit/piers"
DEFAULT_SHIP="dister-bonbud-macryg"
DESK=$DEFAULT_DESK
PIER=$DEFAULT_PIER
SHIP=$DEFAULT_SHIP
BUILD_DIR=""

# --------------------------------------
# MAIN
# --------------------------------------

# Parse arguments
OPTS=":hb:d:p:r:s:"
while getopts ${OPTS} opt; do
  case ${opt} in
    h)
      usage 0
      ;;
    b)
      BUILD_DIR=$OPTARG
      ;;
    d)
      DESK=$OPTARG
      ;;
    p)
      PIER=$OPTARG
      ;;
    r)
      PIER=$OPTARG
      INSTALL_VIA_SSH=true
      ;;
    s)
      SHIP=$OPTARG
      ;;
    :)
      echo "$SCRIPT_NAME: Missing argument for '-${OPTARG}'" >&2
      usage 2
      ;;
    ?)
      echo "$SCRIPT_NAME: Invalid option '-${OPTARG}'" >&2
      usage 2
      ;;
  esac
done

if [ -z "${BUILD_DIR}" ]; then
  echo "$SCRIPT_NAME: -b PATH_TO_UI_BUILD is required" >&2
  usage 2
fi

# Copy files
INSTALL_DIR="$PIER/$SHIP/$DESK"

echo "Attempting to install to path '$INSTALL_DIR'"

if [[ $INSTALL_VIA_SSH == true ]]; then
  scp -r ${CHESS_DIR}/* ${INSTALL_DIR}/
  scp -r ${DEPS_DIR}/* ${INSTALL_DIR}/
  scp -r ${RESOURCE_DIR}/* ${INSTALL_DIR}/
  copy_ui_build "${BUILD_DIR}" "${INSTALL_DIR}/web"
else
  cp -rfL ${CHESS_DIR}/* ${INSTALL_DIR}/
  cp -rfL ${DEPS_DIR}/* ${INSTALL_DIR}/
  cp -rfL ${RESOURCE_DIR}/* ${INSTALL_DIR}/
  copy_ui_build "${BUILD_DIR}" "${INSTALL_DIR}/web"
fi

echo "Successfully installed to path '$INSTALL_DIR'"
