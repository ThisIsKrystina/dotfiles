#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="${1:?Usage: ./new-project.sh <name>}"
DIR="$(pwd)/${PROJECT_NAME}"

# Create structure

mkdir -p  "$DIR"/{src,tests/test_helper}

# Add helper libraries as submodules? 

cd "${DIR}"
# git init
# git submodule add https://github.com/bats-core/bats-support .git tests/test_helper/bats-support
# Ditto, but for bats-assert

# SAMPLE TEST
cat > "${DIR}/tests/example.bats" <<'EOF'
setup() {
	_common_setup
}

@test "placeholder" {
	assert_success
}
EOF

# Create Makefile
cat > "${DIR}/Makefile" <<'EOF'
.PHONY: lint test all

lint:
\tshellcheck src/*.sh

test:
\tbats tests/

all: lint test
EOF

# Sample script
cat > "${DIR}/src/main.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "Hello from ${PROJECT_NAME}"
EOF
chmod +x "${DIR}/src/main.sh"

echo "✅ Project '${PROJECT_NAME}' scaffolded."
echo "   cd ${PROJECT_NAME} && make all"
