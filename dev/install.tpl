#!/bin/bash

# defs & params
FUNC=$1
LOCAL=$HOME/.gsw-tool
PROFILES=$LOCAL/profiles
MD5SCRIPT="{{md5script}}"
MD5FUNC="{{md5func}}"
URL="{{url}}"

# print usage if requested
if [ "--help" == "$1" -o "help" == "$1" ]; then
  echo "Usage:"
  echo "  install.sh [<funcname>=gsw]"
  echo ""
  exit 0
fi

# fallback for func name
if [ -z "$FUNC" ]; then
  FUNC='gsw'
fi

echo "=> Using function name: $FUNC"

# check for curl
dwl=$(which curl)
dwlq="$?"
if [ -z "$dwl" -o "$dwlq" != "0" ]; then
  echo "ERR: curl binary not in PATH"
  exit 1
fi

echo "=> Checking install dir: $LOCAL"

# create directories
if [ ! -d "$PROFILES" ]; then
  mkdir -p $PROFILES
fi

echo "=> Downloading resources and configuring"

# download resources
curl -sSL "$URL/gsw.sh" > $LOCAL/gsw.sh
chmod +x $LOCAL/gsw.sh
MD5S=$(md5sum $LOCAL/gsw.sh | cut -d " " -f 1)
if [ -z "$(cat $LOCAL/gsw.sh)" -o "$MD5SCRIPT" != "$MD5S" -o ! -x "$LOCAL/gsw.sh" ]; then
  echo "ERR: could not download script from $URL/gsw.sh"
  exit 1
fi
curl -sSL "$URL/gsw.func" > $LOCAL/gsw.func
MD5F=$(md5sum $LOCAL/gsw.func | cut -d " " -f 1)
if [ -z "$(cat $LOCAL/gsw.func)" -o "$MD5FUNC" != "$MD5F" ]; then
  echo "ERR: could not download function from $URL/gsw.func"
  exit 1
fi
# add configuration files
echo "export GSW_TOOl_FUNC_NAME=$FUNC" > $LOCAL/gsw.funcname
echo "export GSW_TOOl_BIN_PATH=$LOCAL/gsw.sh" > $LOCAL/gsw.binpath

echo "=> Detecting user shell profile"

# detect a user profile to inject into
if [ -f "$HOME/.bash_profile" ]; then
  FILE="$HOME/.bash_profile"
elif [ -f "$HOME/.profile" ]; then
  FILE="$HOME/.profile"
else
  echo "ERR: neither .bash_profile nor .profile were found in $HOME"
  echo "ERR: Instalatoon did not complete. You won't have the function \`$FUNC\` available"
  echo "ERR: You need to fix this yourself by creating one of the above files"
  echo ""
  echo "INF: In the meanwhile you can still use the \`$FUNC\`function in any terminal,"
  echo "INF: beforehand manually executing:"
  echo ""
  echo "source $LOCAL/gsw.func"
  echo ""
  exit 1
fi

echo "=> Using user profile: $FILE"

# compose user profile line
APPEND="\n# BEGIN gsw-tool: lines added by gsw-tool\nsource $LOCAL/gsw.func\n# END gsw-tool\n"
# detect previous installations
CURRENT=$(cat "$FILE" | grep "$LOCAL/gsw.func")
if [ -z "$CURRENT" ]; then
  echo "=> Sourcing function in $FILE"
  echo -e "$APPEND" >> $FILE
else
  echo "=> Function already sourced in $FILE"
fi

# installation complete info
echo "=> Installation complete"
echo ""
echo "You may use the \`$FUNC\` tool in this session by manually executing:"
echo ""
echo "source $LOCAL/gsw.func"
echo ""
