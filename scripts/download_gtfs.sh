#!/usr/bin/env bash
# Download GTFS archives for Stillway station coverage.
# JP (ODPT) and FR (IDFM) require free registration — pass URLs via env vars.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/data/gtfs"
mkdir -p "$DEST"

download() {
  local name="$1"
  local url="$2"
  echo "→ $name"
  if curl -fL --retry 3 -o "$DEST/${name}.zip" "$url"; then
    echo "  saved $DEST/${name}.zip"
  else
    echo "  skipped $name"
  fi
}

download "us_nyc" "https://feeds.nyc.gov/NYC_GTFS.zip"
download "gb_bods" "https://data.bus-data.dft.gov.uk/timetable/download/gtfs-file/all/"

if [[ -n "${ODPT_GTFS_URL:-}" ]]; then
  download "jp_tokyo_metro" "$ODPT_GTFS_URL"
else
  echo "→ jp_tokyo_metro: set ODPT_GTFS_URL (ODPT API key required)"
fi

if [[ -n "${IDFM_GTFS_URL:-}" ]]; then
  download "fr_idfm" "$IDFM_GTFS_URL"
else
  echo "→ fr_idfm: set IDFM_GTFS_URL"
fi

if [[ -n "${IBB_GTFS_URL:-}" ]]; then
  download "tr_ibb" "$IBB_GTFS_URL"
else
  echo "→ tr_ibb: set IBB_GTFS_URL (İBB açık veri)"
fi

echo "Done. Run: python3 scripts/build_station_db.py"
