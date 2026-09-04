#!/usr/bin/env python3
"""Rename Stillway sound beds to match Sound.swift fileName values.

Run on your Mac:
  cd /Users/sinan/autoresearch
  python3 scripts/normalize_sounds.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOUNDS = ROOT / "Stillway" / "Resources" / "Sounds"

# Canonical names from Sound.swift (context → files)
CANONICAL = {
    "tokyo_metro": "commute",
    "shinkansen": "commute",
    "paris_metro": "commute",
    "istanbul_ferry": "commute",
    "tokyo_rain": "focus",
    "deep_train": "focus",
    "night_cafe": "focus",
    "minka_library": "focus",
    "kyoto_bamboo": "reset",
    "temple_bell": "reset",
    "rain_window": "reset",
    "night_forest": "sleep",
}

# Fuzzy aliases → canonical stem (no extension)
ALIASES: dict[str, str] = {
    "tokyo_metro": "tokyo_metro",
    "tokyometro": "tokyo_metro",
    "tokyo metro": "tokyo_metro",
    "metro tokyo": "tokyo_metro",
    "shinkansen": "shinkansen",
    "shinkansen cabin": "shinkansen",
    "paris_metro": "paris_metro",
    "parismetro": "paris_metro",
    "paris metro": "paris_metro",
    "istanbul_ferry": "istanbul_ferry",
    "istanbulferry": "istanbul_ferry",
    "istanbul ferry": "istanbul_ferry",
    "bosphorus ferry": "istanbul_ferry",
    "tokyo_rain": "tokyo_rain",
    "tokyorain": "tokyo_rain",
    "tokyo rain": "tokyo_rain",
    "deep_train": "deep_train",
    "deeptrain": "deep_train",
    "deep train": "deep_train",
    "night_cafe": "night_cafe",
    "nightcafe": "night_cafe",
    "night cafe": "night_cafe",
    "minka_library": "minka_library",
    "minkalibrary": "minka_library",
    "minka library": "minka_library",
    "kyoto_bamboo": "kyoto_bamboo",
    "kyotobamboo": "kyoto_bamboo",
    "kyoto bamboo": "kyoto_bamboo",
    "temple_bell": "temple_bell",
    "templebell": "temple_bell",
    "temple bell": "temple_bell",
    "rain_window": "rain_window",
    "rainwindow": "rain_window",
    "rain window": "rain_window",
    "night_forest": "night_forest",
    "nightforest": "night_forest",
    "night forest": "night_forest",
}


def normalize_key(name: str) -> str:
    stem = Path(name).stem
    stem = re.sub(r"\s*\(\d+\)$", "", stem)  # "foo (1)"
    stem = stem.replace("-", " ").replace("_", " ")
    stem = re.sub(r"\s+", " ", stem).strip().lower()
    compact = stem.replace(" ", "")
    if stem in ALIASES:
        return ALIASES[stem]
    if compact in ALIASES:
        return ALIASES[compact]
    # contains match
    for alias, canon in ALIASES.items():
        if " " in alias and alias in stem:
            return canon
        if alias.replace(" ", "") in compact and len(alias) > 4:
            return canon
    return ""


def main() -> int:
    if not SOUNDS.is_dir():
        print(f"Missing folder: {SOUNDS}", file=sys.stderr)
        return 1

    files = sorted(
        p for p in SOUNDS.iterdir()
        if p.is_file() and p.suffix.lower() in {".m4a", ".mp3", ".wav", ".aac", ".caf"}
    )
    print("=== Current files ===")
    if not files:
        print("(empty — copy your Suno exports here first)")
        return 1
    for p in files:
        print(f"  {p.name}")

    print("\n=== Plan ===")
    used: set[str] = set()
    plan: list[tuple[Path, Path]] = []
    unmatched: list[Path] = []

    for src in files:
        canon = normalize_key(src.name)
        if not canon:
            unmatched.append(src)
            print(f"  ? {src.name}  →  (no match)")
            continue
        if canon in used:
            print(f"  ! {src.name}  →  {canon}.m4a  (duplicate, skip)")
            continue
        dest = SOUNDS / f"{canon}.m4a"
        used.add(canon)
        if src.resolve() == dest.resolve():
            print(f"  = {src.name}  (already OK, {CANONICAL[canon]})")
            continue
        print(f"  → {src.name}  →  {canon}.m4a  [{CANONICAL[canon]}]")
        plan.append((src, dest))

    missing = [c for c in CANONICAL if c not in used and not (SOUNDS / f"{c}.m4a").exists()]
    if missing:
        print("\n=== Still missing ===")
        for c in missing:
            print(f"  - {c}.m4a  ({CANONICAL[c]})")

    if unmatched:
        print("\n=== Unmatched (rename manually or tell the agent the list) ===")
        for p in unmatched:
            print(f"  - {p.name}")

    if not plan:
        print("\nNothing to rename.")
        return 0

    if "--apply" not in sys.argv:
        print("\nDry-run only. Apply with:")
        print("  python3 scripts/normalize_sounds.py --apply")
        return 0

    for src, dest in plan:
        if dest.exists() and src.resolve() != dest.resolve():
            print(f"Target exists, skip: {dest.name}")
            continue
        # Convert non-m4a by rename only if already m4a; else keep extension note
        if src.suffix.lower() != ".m4a":
            print(f"Note: {src.name} is {src.suffix}; renaming to .m4a (re-export AAC if playback fails)")
        src.rename(dest)
        print(f"Renamed: {dest.name}")

    print("\nDone. Xcode → Clean Build Folder → Run.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
