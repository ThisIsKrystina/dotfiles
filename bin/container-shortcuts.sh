# Anything with PG
run_pg() {
local command="$1"
PG_CONTAINER="postgres-shared"

printf "$command" | docker exec -i "$PG_CONTAINER" psql -U postgres
}

# --- Docker: fuzzy-pick a container, exec in ---
dock() {
  docker ps --format '{{.Names}}' | fzf | xargs -I{} docker exec -it {} sh
}
