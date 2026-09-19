#!/usr/bin/env python3
"""Build Stillway/Resources/stations.json from GTFS zip files in data/gtfs/.

Filters transit_type to metro / rail / tram / ferry (GTFS route_type 0,1,2,4)
and writes a compact JSON array consumed by StationDatabase.
"""

from __future__ import annotations

import csv
import io
import json
import pathlib
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
GTFS_DIR = ROOT / "data" / "gtfs"
OUT = ROOT / "Stillway" / "Resources" / "stations.json"

ROUTE_TYPE_MAP = {
    "0": "tram",
    "1": "metro",
    "2": "rail",
    "4": "ferry",
}


def country_from_name(name: str) -> str:
    lowered = name.lower()
    if "nyc" in lowered or "us_" in lowered:
        return "US"
    if "gb" in lowered or "london" in lowered:
        return "GB"
    if "fr" in lowered or "idfm" in lowered:
        return "FR"
    if "jp" in lowered or "tokyo" in lowered:
        return "JP"
    if "tr" in lowered or "ibb" in lowered:
        return "TR"
    return "UN"


def read_gtfs_table(zf: zipfile.ZipFile, name: str) -> list[dict[str, str]]:
    match = next((n for n in zf.namelist() if n.lower().endswith(name)), None)
    if not match:
        return []
    with zf.open(match) as handle:
        text = io.TextIOWrapper(handle, encoding="utf-8-sig", errors="replace")
        return list(csv.DictReader(text))


def ingest_zip(path: pathlib.Path) -> list[dict]:
    country = country_from_name(path.stem)
    stations: list[dict] = []
    with zipfile.ZipFile(path) as zf:
        routes = {row["route_id"]: row for row in read_gtfs_table(zf, "routes.txt") if "route_id" in row}
        allowed_routes = {
            rid: ROUTE_TYPE_MAP[row.get("route_type", "")]
            for rid, row in routes.items()
            if row.get("route_type") in ROUTE_TYPE_MAP
        }
        trips = read_gtfs_table(zf, "trips.txt")
        stop_ids: dict[str, str] = {}
        if allowed_routes and trips:
            trip_route = {t["trip_id"]: t.get("route_id") for t in trips}
            for stop_time in read_gtfs_table(zf, "stop_times.txt"):
                route_id = trip_route.get(stop_time.get("trip_id", ""))
                if route_id in allowed_routes:
                    stop_ids[stop_time["stop_id"]] = allowed_routes[route_id]
        for stop in read_gtfs_table(zf, "stops.txt"):
            sid = stop.get("stop_id")
            if not sid:
                continue
            if stop_ids and sid not in stop_ids:
                # Keep parent stations if they look like rail/metro names.
                if stop.get("location_type") not in {"1", ""}:
                    continue
            try:
                lat = float(stop["stop_lat"])
                lon = float(stop["stop_lon"])
            except (KeyError, TypeError, ValueError):
                continue
            transit = stop_ids.get(sid, "metro").upper()
            if transit == "METRO":
                transit = "METRO"
            stations.append(
                {
                    "id": f"{country.lower()}-{path.stem}-{sid}",
                    "name": stop.get("stop_name") or sid,
                    "name_en": stop.get("stop_name") or sid,
                    "lat": lat,
                    "lon": lon,
                    "country": country,
                    "city": path.stem,
                    "type": transit,
                    "lines": [],
                }
            )
    return stations


def main() -> None:
    zips = sorted(GTFS_DIR.glob("*.zip")) if GTFS_DIR.exists() else []
    stations: list[dict] = []
    for path in zips:
        print(f"ingest {path.name}")
        stations.extend(ingest_zip(path))

    # Dedup by rounded coordinate
    unique: dict[tuple, dict] = {}
    for station in stations:
        key = (round(station["lat"], 4), round(station["lon"], 4), station["country"])
        unique[key] = station
    out = list(unique.values())
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"wrote {len(out)} stations → {OUT}")


if __name__ == "__main__":
    main()
