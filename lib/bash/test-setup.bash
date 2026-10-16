# Every test for bash will load these helpers
#@example load 'test_helper/common-setup'
# setup() {
#	_common_setup
#}
_common_setup() {
	load 'test_helper/bats-support/load'
	load 'test_helper/bats-assert/load'
	PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
	PATH="${PROJECT_ROOT}/src:${PATH}"
	}

	test_file_exists(){
		[[ -f "$1" ]] || { echo "Expected file to exist: $1"; return 1; }
	}
	test_file_contains(){
		grep -q "$2" "$1" || { echo "File $1 does not contain '$2'"; return 1;}
	}
	mock_command(){
		local cmd="$1"
		local output="$2"
		cat > "${BATS_TEST_TMP_DIR}/bin/${cmd}" <<EOF
		#!/usr/bin/env bash
		echo "${output}"
EOF
		
		chmod +x "${BATS_TEST_TMPDIR}/bin/${cmd}"
		export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
	}
