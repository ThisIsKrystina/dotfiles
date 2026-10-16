property jqFilter : "
jq -s 'map(.alfredsnippet | {name, keyword, text: .snippet})' *.json > collection_output.json"
do shell script jqFilter
