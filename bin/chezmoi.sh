#!/bin/bash

chezmoi_safe() {
	local source_path branch
	source_path=$(chezmoi source-path)
	branch=$(git -C "${source_path}" branch --show-current)

	if [[ "${branch}" != "prod" ]]; then
		echo "On branch ${branch} (expected 'prod'). Switching back..."
		git -C "${source_path}" checkout prod
	fi

	chezmoi "$@"
}