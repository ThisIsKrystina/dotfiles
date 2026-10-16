#!/bin/bash

DOTFILES_HOME=$(chezmoi source-path)

# @description - Check if a program or command exists first
# @example - `if has brew; then eval "$(brew shellenv)" fi

has() { 
local name=$1 #@
command -v "${name}" &>/dev/null;
 
}

#Checks before running a command
#@example 

run_if() { 
local name=$1 #@
has "$1" && shift && "$@"; 
}

# @description - Source every *.<ext> script in a directory, with optional skips.
# @param string $1 - directory to scan (required)
# @param string $2 - file extension WITHOUT the dot (default: sh)
# @param string ... - optional filenames to skip, e.g. 00-config.env
# @example - src_dir ~/Projects/_active/dotfiles/bin sh 01-helpers.sh
src_dir() {
	# Pass a DIRECTORY, not a glob. A glob (*.sh) expands in the CALLER's
	# shell first, so the function would only ever see the first match.
	local dir="${1:?src_dir: need a directory path}"
	local ext="${2:-sh}"
	local excludes=("${@:3}") # everything after ext = files to skip

	local file base skip ex
	for file in "${dir}"/*."${ext}"; do
		# If nothing matches, the glob stays literal — skip that phantom entry
		[[ -e "${file}" ]] || continue

		base="${file##*/}" # strip the path, keep just the filename
		skip=""
		for ex in "${excludes[@]}"; do
			[[ "${base}" == "${ex}" ]] && { skip=1; break; }
		done
		[[ -n "${skip}" ]] && continue

		source "${file}"
	done
}


# @description Check if our shell options are set correctly, if not then fix. 
# @param string $1 - name of the option (e.g. globstar, nocaseglob)
# @param boolean $2 - 1 for on, 0 for disable  
ensure_shopt() {
    local entry opt desired
    for entry in "$@"; do
        opt="${entry%%=*}"
        desired="${entry##*=}"

        case "$desired" in
            1|on|true)
                if ! shopt -q "$opt" 2>/dev/null; then
                    shopt -s "$opt"
                    echo "Enabled: $opt"
                fi
                ;;
            0|off|false)
                if shopt -q "$opt" 2>/dev/null; then
                    shopt -u "$opt"
                    echo "Disabled: $opt"
                fi
                ;;
        esac
    done
}

install_completion() {
    local cmd="$1"
    local gen_cmd="$2"
    local LOCAL_DIR="${HOME}/.local/bash-completion/bash_completion.d"
    local DIR="${LOCAL_DIR}/${cmd}"
    # Error handler 
    die_on_fail "Completion file not created." \
        bash -c "mkdir -p ${DIR}" env --chdir="${DIR}" bash -c "${gen_cmd} > ${DIR}/${cmd}.bash"
        exit_status=$?
        if [ "${exit_status}" -eq 0 ]; then
          echo "Installed completion for ${cmd} '->' ${DIR}/${cmd}.bash"
        fi
}

# @description Add to path by appending to a .bashrc file
# @param string $1 - Directory / filepath to append, single quoted

add_to_path() {
    local dir="${1%/}"   # strip trailing slash
    local bashrc="${DOTFILES_HOME}/private_dot_bashrc.d/03-path.bashrc.tmpl"
    local new_path="${PATH}:${dir}"
    #Setting literal here so it doesn't unfurl too early
    LINE='[[":${PATH}:" != *":'"${dir}"':"* ]] && export PATH="${PATH}:'"${dir}"'"'

    # Skip if its already in the live path right now
    case ":${PATH}:" in
        *":${dir}:"*) return 0 ;;
    esac

    # Checks .bashrc file first before appending
    if ! grep -qF ":${dir}:" "${bashrc}"; then
    printf '%s\n' "${LINE}" >> "${bashrc}"
        return 0
    fi


    # Apply to current session
    export PATH="${PATH}:${dir}"
}
