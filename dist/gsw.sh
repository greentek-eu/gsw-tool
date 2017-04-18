#!/bin/bash

# defs & env
VERSION="0.1.0-dev"
LOCAL=$HOME/.gsw-tool
SSH=$HOME/.ssh
PROFILES=$LOCAL/profiles
# source function name
if [ -f "$LOCAL/gsw.funcname" ]; then
  source $LOCAL/gsw.funcname
fi
SELF=$GSW_TOOL_FUNC_NAME
if [ -z "$SELF" ]; then
  # fallback
  SELF=gsw
fi

# error codes

C_SUCC_DO_NOTHING=0
C_SUCC_SET_VAR=100
C_ERR_INVALID_ARG=1
C_ERR_VALIDATION=2
C_ERR_RUNTIME=3

# help

usage() { 
  pr "Usage:
  <info>$SELF <argument> <note>[args ...]</note></info>
Argument:
  <info>help</info>
    Prints this help
  <info>use <profile></info>
    Sets up the wrapper profile <info><profile></info> to be used in current shell
  <info>reset</info>
    Clears the use of current wrapper (sets GIT_SSH_COMMAND to an empty string)
  <info>ls</info>
    Show currently defined wrappers
  <info>map <profile> \"<ssh_command>\"</info>
    Creates a wrapper <info><profile></info> with supplied ssh command
    Eg:
      ~$ # this will save the <note>work</note> profile with <note>\"ssh -i /home/me/.ssh/work\"</note> command
      ~$ $SELF map work \"ssh -i /home/me/.ssh/work\"
  <info>mapkey <keyname></info>
    Same as <info>map</info>, except it assumes in the above example that you
    supplied a key file name from ~/.ssh directory, and autocompltes the rest
  <info>rm <profile></info>
    Removes a wrapper profile
  <info>versio</info>
    Prints version

";
}

# dispatcher

execute() {
  local arg="$1"
  local profile="$2"
  local cmd="$3"
  # dispatch
  if [ "$arg" == "use" ]; then
    use "$profile"
  elif [ "$arg" == "reset" ]; then
    reset
  elif [ "$arg" == "ls" ]; then
		list
	elif [ "$arg" == "map" ]; then
		map "$profile" "$cmd"
  elif [ "$arg" == "mapkey" ]; then
		mapkey "$profile" "$cmd"
	elif [ "$arg" == "rm" ]; then
		remove "$profile"
	elif [ "$arg" == "help" -o "$arg" == "--help" ]; then
		usage
  elif [ "$arg" == "version" -o "$arg" == "--version" ]; then
		version
	else
    noarg "$arg"
	fi
}

# actions

use() {
  local profile="$1"
  profile_exists "$profile"
  cat $PROFILES/$profile
  exit $C_SUCC_SET_VAR
}

reset() {
  echo -n ""
  exit $C_SUCC_SET_VAR
}

map() {
  local profile=$1 cmd="$2"
  not_empty profile "$profile"
  echo "$cmd" > "$PROFILES/$profile"
  exit $C_SUCC_DO_NOTHING
}

mapkey() {
  local profile=$1 key="$2"
  not_empty keyname "$key"
  key_exists_in_home "$key"
  map "$profile" "ssh -i $SSH/$key"
  exit $C_SUCC_DO_NOTHING
}

list() {
  pr "Wrapper profiles:"
  for profile in $(ls -1 $PROFILES); do
    pr "* <info>$profile</info>"
    pr "  $(cat $PROFILES/$profile)"
  done
  exit $C_SUCC_DO_NOTHING
}

remove() {
  local profile="$1"
  if [ -f "$PROFILES/$profile" ]; then
    rm "$PROFILES/$profile"
  fi
  exit $C_SUCC_DO_NOTHING
}

noarg() {
  local arg="$1"
  err "<error>ERR: unknown argument [$arg].</error><warn>Try: $SELF help</warn>"
  exit $C_ERR_INVALID_ARG
}

version() {
  echo $VERSION
  exit $C_SUCC_DO_NOTHING
}

# helpers

pr() {
  local msg=$(color "$1")
  echo -e "$msg"
}

err() {
  local msg=$(color "$1")
  >&2 echo -e "$msg"
}

color() {
  local text="$1"
  text=$(echo "$text" | sed 's#<info>#\\033[0;32m#g' | sed 's#</info>#\\033[00m#g')
  text=$(echo "$text" | sed 's#<error>#\\033[1;31m#g' | sed 's#</error>#\\033[00m#g')
  text=$(echo "$text" | sed 's#<warn>#\\033[1;33m#g' | sed 's#</warn>#\\033[00m#g')
  text=$(echo "$text" | sed 's#<note>#\\033[1;34m#g' | sed 's#</note>#\\033[00m#g')
  echo -ne "$text"
}

# validators

not_empty() {
  local thing=$1 arg="$2"
  if [ -z "$arg" ]; then
    err "<error>ERR[validation]: <warn>$thing</warn><error> cannot be empty</error>"
    exit $C_ERR_VALIDATION
  fi
}

key_exists_in_home() {
  local key="$1"
  if [ ! -f "$SSH/$key" ]; then
    err "<error>ERR[validation]: key <warn>$key</warn><error> must exist in <warn>$SSH/</warn></error>"
    exit $C_ERR_VALIDATION
  fi
}

profile_exists() {
  local profile="$1"
  if [ ! -f "$PROFILES/$profile" ]; then
    err "<error>ERR[validation]: profile <warn>$profile</warn><error> must exist</error>"
    exit $C_ERR_VALIDATION
  fi
}

# kick it

execute "$@"
