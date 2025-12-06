#!/usr/bin/env bash
# A simle program to pretty-print variable contents for debugging purposes.
#
# Autor: Edvin Lidholm
# License: Apache-2.0
# Date: 2025-12-05

vardump() {
  local color=true
  local verbose=false
  local OPTIND opt
  while getopts 'cvh' opt; do
    case "$opt" in
      c) color=false ;;
      v) verbose=true ;;
      h)
        echo "Usage: vardump [-c] [-v] <var_name>"
        echo
        echo "Options:"
        echo "  -c    Disable colored output"
        echo "  -v    Enable verbose output"
        echo "  -h    Show this help message"
        return 0
        ;;
      *)
        echo "Error: unknown option '$opt'" >&2
        return 1
        ;;
    esac
  done
  shift "$((OPTIND -1))"

  var_name=$1
  if [[ -z "$var_name" ]]; then
    echo "Error: missing required argument '<var_name>'" >&2
    return 1
  fi

  if ! declare -p "$var_name" &>/dev/null; then
    echo "variable ${var_name@Q} is not defined" >&2
    return 1
  fi

	if $color; then
		local color_green=$'\e[32m'
		local color_magenta=$'\e[35m'
		local color_rst=$'\e[0m'
		local color_dim=$'\e[2m'
	else
		local color_green=''
		local color_magenta=''
		local color_rst=''
		local color_dim=''
	fi

	local color_value=$color_green
	local color_key=$color_magenta
	local color_length=$color_magenta

	if $verbose; then
		echo "${color_dim}--------------------------${color_rst}"
		echo "${color_dim}vardump: ${color_rst}$var_name"
	fi

  if [[ "$(declare -p "$var_name")" =~ ^declare\ -a ]]; then
    local type="indexed array"
  elif [[ "$(declare -p "$var_name")" =~ ^declare\ -A ]]; then
    local type="associative array"
  else
    local type="scalar"
  fi

  local -n __vardump_name="$var_name"

  if $verbose; then
    echo "${color_dim}type: ${color_rst}$type"
  fi


  if [[ "$type" != "scalar" ]]; then
    if $verbose; then
      local length=${#__vardump_name[@]}
      printf '%s %s\n' \
          "${color_dim}length:${color_rst}" \
          "${color_length}$length${color_rst}"
    fi

    echo '('
    for key in "${!__vardump_name[@]}"; do
      value=${__vardump_name[$key]}

      if [[ $type == 'associative array' ]]; then
				key=${key@Q}
			fi

      value=${value@Q}

      printf '    [%s]=%s\n' \
        "${color_key}$key${color_rst}" \
        "${color_value}$value${color_rst}"
      done
      echo ')'

  else
    local value=${__vardump_name@Q}
    echo "${color_value}${__vardump_name@Q}${color_rst}"
  fi


	if $verbose; then
		echo "${color_dim}--------------------------${color_rst}"
	fi

	return 0
}
