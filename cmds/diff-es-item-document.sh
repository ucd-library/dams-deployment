#! /bin/bash
#
# Verifies argonath's `digtk public-dc es upsert <ark>` writes a document
# equivalent to (or an intentional improvement on) fin dbsync's current
# output for the same item - docs/PORT-PLAN.md (dams repo) Phase 3's
# "done when"/Verification step. NOT run automatically - a runbook, meant
# to be read and run by hand against a real item before trusting the new
# indexing path for a collection.
#
# Not a general reindex-diff tool: it snapshots ONE item's document before
# and after a single re-index call, on the assumption the "before" snapshot
# was written by the currently-live path (fin dbsync) and the "after" one
# by argonath. If both paths are already writing to the same alias
# concurrently, the "before" snapshot may already be argonath's - check
# which pipeline last touched the item before relying on this.
#
# Usage:
#   ./diff-es-item-document.sh <ark> [es-host] [index]
#     ark      e.g. ark:/87287/d73035
#     es-host  default http://localhost:9200 (local-dev compose port)
#     index    default item-read (see services/client/lib/es-model.js -
#              read/write aliases are both named off the model, "item-read"/
#              "item-write"; the dams client only ever reads item-read)
#
# Requires: curl, jq, and shell access to wherever `digtk public-dc es
# upsert` actually runs (a Dagster/digtk environment - this script does not
# attempt to invoke it, since that's argonath's own CLI/environment, not
# dams's).
#
set -e

ARK="$1"
ES_HOST="${2:-http://localhost:9200}"
INDEX="${3:-item-read}"

if [[ -z "$ARK" ]]; then
  echo "Usage: $0 <ark> [es-host] [index]"
  exit 1
fi

# Matches the document envelope's own @id shape (services/client/models/item/
# transform.js's ARCHIVAL_GROUP_REGEX / argonath's dams_index.py fin_path) -
# both build "/item/{ark}" as the ES doc id, not the bare ark.
DOC_ID="/item/${ARK}"
ENCODED_ID=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$DOC_ID")

fetch() {
  curl -sf "$ES_HOST/$INDEX/_doc/$ENCODED_ID" | jq '._source'
}

echo "Fetching current (\"before\") document for $DOC_ID from $ES_HOST/$INDEX ..."
BEFORE=$(fetch) || { echo "No existing document found - is this ark indexed yet?"; exit 1; }
BEFORE_FILE=$(mktemp)
echo "$BEFORE" | jq --sort-keys . > "$BEFORE_FILE"
echo "Saved to $BEFORE_FILE"

echo ""
echo "Now, in an argonath/digtk environment, run:"
echo "  digtk public-dc es upsert $ARK"
read -p "Press enter once that command has completed..." _

echo "Fetching document again (\"after\") ..."
AFTER=$(fetch)
AFTER_FILE=$(mktemp)
echo "$AFTER" | jq --sort-keys . > "$AFTER_FILE"
echo "Saved to $AFTER_FILE"

echo ""
echo "=== Full diff (before -> after) ==="
diff -u "$BEFORE_FILE" "$AFTER_FILE" || true

echo ""
echo "=== Fields this port's Phase 2/3 findings flagged as load-bearing ==="
for field in '.["@id"]' '.name' '.roles' '."@graph"[0].clientMedia' '."@graph"[0].isPartOf'; do
  b=$(jq -c "$field // \"<absent>\"" "$BEFORE_FILE" 2>/dev/null)
  a=$(jq -c "$field // \"<absent>\"" "$AFTER_FILE" 2>/dev/null)
  if [[ "$b" != "$a" ]]; then
    echo "CHANGED $field:"
    echo "  before: $b"
    echo "  after:  $a"
  else
    echo "match   $field: $a"
  fi
done

rm -f "$BEFORE_FILE" "$AFTER_FILE"
