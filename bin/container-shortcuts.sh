# Anything with PG
run_pg() {
local command="$1"
local pg_container="postgres-shared"

# '%s' keeps the SQL literal — a bare "${command}" would treat any % as a
# printf format directive and mangle the query.
printf '%s\n' "${command}" | docker exec -i "${pg_container}" psql -U postgres
}

# --- Docker: fuzzy-pick a container, exec in ---
dock() {
  docker ps --format '{{.Names}}' | fzf | xargs -I{} docker exec -it {} sh
}
