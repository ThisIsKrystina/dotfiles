# Alfred Script Filter: list all entries
jq -r 'to_entries[] | .key + "\t" + (.value | join(", "))' ~/.snip_params.json | \
  while IFS=$'\t' read -r func params; do
    echo "{\"arg\":\"$func\",\"title\":\"$func\",\"subtitle\":\"$params\"}"
  done
