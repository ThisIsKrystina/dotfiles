#!/usr/bin/env bash
#
# todo-sync.sh — nudge (then escalate to blocking) when todos are marked
# complete without syncing a plan / checkbox doc.
# @external jq tool needed
# Wired to two Claude Code hook events:
#   PostToolUse[TodoWrite] : on a NEW todo completion, if no plan doc has
#                            pending changes, increment a per-session drift
#                            counter and nudge — or hard-block once drift
#                            crosses the threshold. Any dirty plan doc resets
#                            the counter to 0.
#   PreToolUse[Bash]       : hard-gate `git commit` while drift > 0, so work
#                            can't be committed carrying unsynced completions.
#
# "Soft on good days, firm on sloppy ones" — the counter measures drift, so
# nothing is ever self-assessed or toggled by hand.
#
# ---------------------------------------------------------------------------
# Config (env vars, all optional):
#   TODO_SYNC_NAME_FILTER     Comma list of case-insensitive filename
#                             substrings (e.g. "plan,task,todo,roadmap").
#                             Empty = match ANY tracked .md that has checkboxes.
#                             Set it to ignore checkbox docs whose names don't
#                             match (e.g. an Obsidian wishlist).
#   TODO_SYNC_BLOCK_THRESHOLD Drift count that flips nudge -> block. Default 3.
#   TODO_SYNC_STATE_DIR       Where per-session counters live.
#                             Default "$TMPDIR/claude-todo-sync".
# ---------------------------------------------------------------------------
#
# Contract: reads the hook payload as JSON on stdin, emits a JSON hook
# response on stdout, always exits 0 (control is expressed via the JSON, so a
# non-zero exit is never mistaken for a block). Silent (empty output) means
# "no opinion — proceed".

# NOTE: intentionally NOT using `set -e`. Probes like `git`/`grep` return
# non-zero for benign "not found" cases; we handle each explicitly instead of
# letting the script die mid-hook.
set -uo pipefail
TODO_SYNC_NAME_FILTER="plan,task,todo,roadmap"
# --- config ---------------------------------------------------------------

readonly NAME_FILTER="${TODO_SYNC_NAME_FILTER:-}"
readonly BLOCK_THRESHOLD="${TODO_SYNC_BLOCK_THRESHOLD:-3}"
readonly STATE_DIR="${TODO_SYNC_STATE_DIR:-${TMPDIR:-/tmp}/claude-todo-sync}"

# --- output helpers -------------------------------------------------------

##
# Emit nothing and exit — the hook has no opinion on this event.
#
emit_quiet() {
	exit 0
}

##
# Inject a non-blocking reminder into Claude's context (PostToolUse nudge).
# @param $1 string  Message to surface.
#
emit_nudge() {
	local message="$1"
	jq -n --arg msg "$message" \
		'{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
	exit 0
}

##
# Block the just-run tool result and hand the reason back to Claude
# (PostToolUse escalation once drift crosses the threshold).
# @param $1 string  Reason shown to Claude.
#
emit_block() {
	local reason="$1"
	jq -n --arg reason "$reason" \
		'{decision: "block", reason: $reason}'
	exit 0
}

##
# Deny a tool call before it runs (PreToolUse commit gate).
# @param $1 string  Reason shown to Claude.
#
emit_deny() {
	local reason="$1"
	jq -n --arg reason "$reason" \
		'{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
	exit 0
}

# --- state ----------------------------------------------------------------

##
# Path to this session's state file. Keyed by session id so a new session
# starts clean; falls back to "unknown" when the id is absent.
# @param $1 string  session_id from the hook payload.
# @stdout Absolute path to the state file.
#
state_file() {
	local session_id="${1:-unknown}"
	printf '%s/%s.state' "$STATE_DIR" "$session_id"
}

##
# Read a field from the state file. State format is two lines:
#   line 1: drift_count
#   line 2: last_completed_count
# @param $1 string  State file path.
# @param $2 int     1 for drift_count, 2 for last_completed_count.
# @stdout The value, or 0 when missing.
#
read_state_line() {
	local file="$1" line_no="$2"
	if [[ ! -f "$file" ]]; then
		printf '0'
		return
	fi
	local value
	value="$(sed -n "${line_no}p" "$file")"
	printf '%s' "${value:-0}"
}

##
# Persist state.
# @param $1 string  State file path.
# @param $2 int     drift_count.
# @param $3 int     last_completed_count.
#
write_state() {
	local file="$1" drift="$2" last_completed="$3"
	mkdir -p "$(dirname "$file")"
	printf '%s\n%s\n' "$drift" "$last_completed" >"$file"
}

# --- plan-doc detection ---------------------------------------------------

##
# Does a filename match the optional name filter? Always true when no filter
# is configured. Case-insensitive substring match against the basename.
# @param $1 string  File path.
# @return 0 if it matches (or no filter set), 1 otherwise.
#
matches_name_filter() {
	local path="$1"
	[[ -z "$NAME_FILTER" ]] && return 0

	local base
	base="$(basename "$path")"
	base="$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')"

	local IFS=','
	local needle
	for needle in $NAME_FILTER; do
		needle="$(printf '%s' "$needle" | tr '[:upper:]' '[:lower:]' | xargs)" # trim
		[[ -z "$needle" ]] && continue
		[[ "$base" == *"$needle"* ]] && return 0
	done
	return 1
}

##
# Is this file a "plan doc"? A tracked .md that contains checkbox syntax
# (`- [ ]` / `- [x]`) and passes the optional name filter.
# @param $1 string  File path (relative to repo root).
# @return 0 if it counts as a plan doc, 1 otherwise.
#
is_plan_doc() {
	local path="$1"
	[[ "$path" == *.md ]] || return 1
	[[ -f "$path" ]] || return 1
	matches_name_filter "$path" || return 1
	# checkbox syntax, unchecked or checked
	grep -qiE '^\s*[-*] \[[ xX]\]' "$path" 2>/dev/null
}

##
# Does at least one plan doc have pending (uncommitted) changes right now?
# This is our "you're syncing" signal.
# @return 0 if a dirty plan doc exists, 1 otherwise (incl. not-a-repo).
#
plan_doc_is_dirty() {
	git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

	local changed
	# --porcelain -> "XY path"; strip the 3-char status prefix. -z would be
	# safer for exotic filenames, but line mode keeps this readable and plan
	# docs don't carry newlines in their names.
	changed="$(git status --porcelain -- '*.md' 2>/dev/null | cut -c4-)"
	[[ -z "$changed" ]] && return 1

	local path
	while IFS= read -r path; do
		[[ -z "$path" ]] && continue
		if is_plan_doc "$path"; then
			return 0
		fi
	done <<<"$changed"
	return 1
}

# --- event handlers -------------------------------------------------------

##
# PostToolUse[TodoWrite]: detect a NEW completion, then nudge/block on drift.
# @param $1 string  Raw hook payload JSON.
#
handle_todo_write() {
	local payload="$1"
	local session_id completed_now
	session_id="$(jq -r '.session_id // "unknown"' <<<"$payload")"
	completed_now="$(jq -r '[.tool_input.todos[]? | select(.status == "completed")] | length' <<<"$payload")"

	local file drift last_completed
	file="$(state_file "$session_id")"
	drift="$(read_state_line "$file" 1)"
	last_completed="$(read_state_line "$file" 2)"

	# A dirty plan doc means syncing is underway — clear drift no matter what
	# the todos did. Checked FIRST so "edit the doc, then touch a todo" resets.
	if plan_doc_is_dirty; then
		write_state "$file" 0 "$completed_now"
		emit_quiet
	fi

	# No new completion since last time (or the list was replaced/shrank):
	# record the current count, keep drift as-is, stay quiet.
	if ((completed_now <= last_completed)); then
		write_state "$file" "$drift" "$completed_now"
		emit_quiet
	fi

	# New completion with no plan doc mid-sync — drift grows.
	drift=$((drift + 1))
	write_state "$file" "$drift" "$completed_now"

	if ((drift >= BLOCK_THRESHOLD)); then
		emit_block "$drift todos have been completed without updating a plan/checkbox doc. Update the relevant plan file's checkboxes now (or, if you're a subagent, report the completed items back to the parent so it can sync). This keeps the plan accurate across compaction."
	fi

	emit_nudge "You just completed a todo but no plan/checkbox doc shows pending changes. Reflect this completion in the relevant plan file (tick its checkbox), or report it up if you're a subagent. Unsynced completions so far: $drift/$BLOCK_THRESHOLD before this becomes a hard block."
}

##
# PreToolUse[Bash]: gate `git commit` while drift > 0.
# @param $1 string  Raw hook payload JSON.
#
handle_bash() {
	local payload="$1"
	local command session_id
	command="$(jq -r '.tool_input.command // ""' <<<"$payload")"
	session_id="$(jq -r '.session_id // "unknown"' <<<"$payload")"

	# Only care about commits. Match `git commit`, ignoring flags/paths.
	[[ "$command" =~ (^|[^[:alnum:]])git[[:space:]]+.*commit ]] || emit_quiet

	local file drift last_completed
	file="$(state_file "$session_id")"
	drift="$(read_state_line "$file" 1)"
	((drift == 0)) && emit_quiet

	# If this commit carries a plan-doc change (staged docs read as dirty),
	# the sync is happening now — clear drift and allow the commit.
	if plan_doc_is_dirty; then
		last_completed="$(read_state_line "$file" 2)"
		write_state "$file" 0 "$last_completed"
		emit_quiet
	fi

	emit_deny "Blocked: $drift completed todo(s) haven't been synced to a plan/checkbox doc. Tick the relevant checkboxes and save the doc, then commit — the plan should never lag behind a commit."
}

# --- dispatch -------------------------------------------------------------

main() {
	local payload
	payload="$(cat)"
	[[ -z "$payload" ]] && emit_quiet

	local event tool
	event="$(jq -r '.hook_event_name // ""' <<<"$payload")"
	tool="$(jq -r '.tool_name // ""' <<<"$payload")"

	case "$event/$tool" in
	PostToolUse/TodoWrite) handle_todo_write "$payload" ;;
	PreToolUse/Bash) handle_bash "$payload" ;;
	*) emit_quiet ;;
	esac
}

main
