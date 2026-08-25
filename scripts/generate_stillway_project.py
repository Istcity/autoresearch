#!/usr/bin/env python3
"""Generate Stillway.xcodeproj/project.pbxproj, assets, strings, sample stations."""

from __future__ import annotations

import json
import math
import pathlib
import struct
import zlib
import re

ROOT = pathlib.Path("/workspace")
APP = ROOT / "Stillway"
WIDGETS = ROOT / "StillwayWidgets"
ASSETS = APP / "Resources" / "Assets.xcassets"
COLORS = ASSETS / "Colors"

HEX_COLORS = {
    "ctxCommuteBg": "020818",
    "ctxCommuteMid": "0D1B4D",
    "ctxCommuteEnd": "1B0D4D",
    "ctxCommuteAccent": "4169E1",
    "ctxFocusBg": "020C18",
    "ctxFocusMid": "041B2D",
    "ctxFocusEnd": "062040",
    "ctxFocusAccent": "0A84FF",
    "ctxSleepBg": "050010",
    "ctxSleepMid": "0F0226",
    "ctxSleepEnd": "1A0533",
    "ctxSleepAccent": "5E5CE6",
    "ctxResetBg": "180800",
    "ctxResetMid": "2D1200",
    "ctxResetEnd": "3D1A00",
    "ctxResetAccent": "FF9F0A",
    "ctxWalkingBg": "001208",
    "ctxWalkingMid": "002010",
    "ctxWalkingEnd": "003018",
    "ctxWalkingAccent": "30D158",
    "ctxDeepWorkBg": "150000",
    "ctxDeepWorkMid": "2D0000",
    "ctxDeepWorkEnd": "3D0A0A",
    "ctxDeepWorkAccent": "FF453A",
    "LaunchBackground": "050505",
}

SAMPLE_STATIONS = [
    {"id": "jp-tokyo-ginza", "name": "Ginza", "city": "Tokyo", "country": "JP", "latitude": 35.6717, "longitude": 139.7649, "transitType": "metro"},
    {"id": "jp-tokyo-shibuya", "name": "Shibuya", "city": "Tokyo", "country": "JP", "latitude": 35.6580, "longitude": 139.7016, "transitType": "rail"},
    {"id": "jp-tokyo-shinjuku", "name": "Shinjuku", "city": "Tokyo", "country": "JP", "latitude": 35.6909, "longitude": 139.7003, "transitType": "rail"},
    {"id": "jp-osaka-umeda", "name": "Umeda", "city": "Osaka", "country": "JP", "latitude": 34.7055, "longitude": 135.4983, "transitType": "metro"},
    {"id": "jp-kyoto-kyoto", "name": "Kyoto", "city": "Kyoto", "country": "JP", "latitude": 34.9858, "longitude": 135.7588, "transitType": "rail"},
    {"id": "us-nyc-timesq", "name": "Times Square-42 St", "city": "New York", "country": "US", "latitude": 40.7559, "longitude": -73.9871, "transitType": "metro"},
    {"id": "us-nyc-union", "name": "Union Square", "city": "New York", "country": "US", "latitude": 40.7359, "longitude": -73.9906, "transitType": "metro"},
    {"id": "us-sf-montgomery", "name": "Montgomery", "city": "San Francisco", "country": "US", "latitude": 37.7894, "longitude": -122.4011, "transitType": "rail"},
    {"id": "us-chi-state", "name": "State/Lake", "city": "Chicago", "country": "US", "latitude": 41.8857, "longitude": -87.6278, "transitType": "metro"},
    {"id": "fr-paris-chatelet", "name": "Châtelet", "city": "Paris", "country": "FR", "latitude": 48.8583, "longitude": 2.3475, "transitType": "metro"},
    {"id": "fr-paris-nation", "name": "Nation", "city": "Paris", "country": "FR", "latitude": 48.8483, "longitude": 2.3958, "transitType": "metro"},
    {"id": "fr-lyon-bellecour", "name": "Bellecour", "city": "Lyon", "country": "FR", "latitude": 45.7578, "longitude": 4.8320, "transitType": "metro"},
    {"id": "gb-london-kingsx", "name": "King's Cross St Pancras", "city": "London", "country": "GB", "latitude": 51.5308, "longitude": -0.1238, "transitType": "metro"},
    {"id": "gb-london-oxford", "name": "Oxford Circus", "city": "London", "country": "GB", "latitude": 51.5152, "longitude": -0.1418, "transitType": "metro"},
    {"id": "tr-ist-taksim", "name": "Taksim", "city": "Istanbul", "country": "TR", "latitude": 41.0369, "longitude": 28.9850, "transitType": "metro"},
    {"id": "tr-ist-kadikoy", "name": "Kadıköy", "city": "Istanbul", "country": "TR", "latitude": 40.9909, "longitude": 29.0290, "transitType": "ferry"},
    {"id": "tr-ist-mecidiyekoy", "name": "Mecidiyeköy", "city": "Istanbul", "country": "TR", "latitude": 41.0670, "longitude": 28.9870, "transitType": "metro"},
    {"id": "tr-ank-kizilay", "name": "Kızılay", "city": "Ankara", "country": "TR", "latitude": 39.9208, "longitude": 32.8541, "transitType": "metro"},
    {"id": "tr-izm-konak", "name": "Konak", "city": "Izmir", "country": "TR", "latitude": 38.4192, "longitude": 27.1287, "transitType": "metro"},
]


def hex_to_components(h: str) -> dict:
    r, g, b = (int(h[i : i + 2], 16) / 255 for i in (0, 2, 4))
    return {
        "color-space": "srgb",
        "components": {"red": f"{r:.3f}", "green": f"{g:.3f}", "blue": f"{b:.3f}", "alpha": "1.000"},
    }


def write_json(path: pathlib.Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def write_colorset(name: str, hex_color: str) -> None:
    write_json(
        COLORS / f"{name}.colorset" / "Contents.json",
        {"colors": [{"idiom": "universal", "color": hex_to_components(hex_color)}], "info": {"version": 1, "author": "xcode"}},
    )


def crc(chunk_type: bytes, data: bytes) -> int:
    return zlib.crc32(chunk_type + data) & 0xFFFFFFFF


def png_chunk(chunk_type: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + chunk_type + data + struct.pack(">I", crc(chunk_type, data))


def write_app_icon(path: pathlib.Path, size: int = 1024) -> None:
    rows = []
    for y in range(size):
        row = bytearray()
        ny = y / size
        for x in range(size):
            nx = x / size
            dx, dy = nx - 0.5, ny - 0.52
            radius = math.sqrt(dx * dx + dy * dy)
            waves = 0.0
            for i, (amp, freq, phase, thick) in enumerate(
                [(0.10, 7.5, 0.0, 0.018), (0.07, 9.2, 0.6, 0.014), (0.05, 11.0, 1.2, 0.010)]
            ):
                wy = 0.52 + amp * math.sin(nx * math.pi * freq + phase)
                dist = abs(ny - wy)
                waves += max(0.0, 1.0 - dist / thick) * (1.0 - i * 0.18)
            glow = max(0.0, 1.0 - radius * 1.7) * 0.25
            intensity = min(1.0, waves + glow)
            rr = int(min(255, 8 + intensity * 80 + (1 - nx) * intensity * 27))
            gg = int(min(255, 8 + intensity * 63))
            bb = int(min(255, 8 + intensity * 219))
            row += bytes((rr, gg, bb))
        rows.append(b"\x00" + bytes(row))
    compressed = zlib.compress(b"".join(rows), 9)
    ihdr = struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0)
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n" + png_chunk(b"IHDR", ihdr) + png_chunk(b"IDAT", compressed) + png_chunk(b"IEND", b"")
    )


def write_assets() -> None:
    write_json(ASSETS / "Contents.json", {"info": {"version": 1, "author": "xcode"}})
    write_json(COLORS / "Contents.json", {"info": {"version": 1, "author": "xcode"}})
    for name, hx in HEX_COLORS.items():
        write_colorset(name, hx)
    write_json(
        ASSETS / "AccentColor.colorset" / "Contents.json",
        {"colors": [{"idiom": "universal", "color": hex_to_components("4169E1")}], "info": {"version": 1, "author": "xcode"}},
    )
    icon = ASSETS / "AppIcon.appiconset"
    icon.mkdir(parents=True, exist_ok=True)
    write_app_icon(icon / "AppIcon.png")
    write_json(
        icon / "Contents.json",
        {
            "images": [{"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"}],
            "info": {"version": 1, "author": "xcode"},
        },
    )


def write_xcstrings() -> None:
    source = (APP / "Core" / "Localization" / "LocalizationManager.swift").read_text(encoding="utf-8")
    entry_re = re.compile(
        r'"([a-z0-9_]+)":\s*\[\.tr:\s*"((?:\\.|[^"\\])*)",\s*\.ja:\s*"((?:\\.|[^"\\])*)",\s*\.en:\s*"((?:\\.|[^"\\])*)",\s*\.fr:\s*"((?:\\.|[^"\\])*)"\]',
        re.S,
    )

    def unescape(s: str) -> str:
        return s.encode("utf-8").decode("unicode_escape") if "\\" in s else s

    strings = {}
    for key, tr, ja, en, fr in entry_re.findall(source):
        strings[key] = {
            "localizations": {
                lang: {"stringUnit": {"state": "translated", "value": unescape(val)}}
                for lang, val in (("tr", tr), ("ja", ja), ("en", en), ("fr", fr))
            }
        }
    write_json(
        APP / "Resources" / "Localizable.xcstrings",
        {"sourceLanguage": "en", "strings": strings, "version": "1.0"},
    )
    print(f"xcstrings keys: {len(strings)}")


class IDs:
    def __init__(self) -> None:
        self.n = 0xA10000
        self.seen: dict[str, str] = {}

    def __call__(self, name: str) -> str:
        if name not in self.seen:
            self.n += 1
            self.seen[name] = f"{self.n:024X}"
        return self.seen[name]


def file_type(path: pathlib.Path) -> str:
    return {
        ".swift": "sourcecode.swift",
        ".plist": "text.plist.xml",
        ".entitlements": "text.plist.entitlements",
        ".xcprivacy": "text.xml",
        ".json": "text.json",
        ".xcstrings": "text.json.xcstrings",
        ".xcassets": "folder.assetcatalog",
    }.get(path.suffix, "text")


def generate_pbxproj() -> None:
    nid = IDs()
    app_swifts = sorted(APP.rglob("*.swift"))
    widget_swifts = sorted(WIDGETS.rglob("*.swift"))
    resources = [
        APP / "Resources" / "Assets.xcassets",
        APP / "Resources" / "Localizable.xcstrings",
        APP / "Resources" / "stations.json",
        APP / "PrivacyInfo.xcprivacy",
    ]
    extra_app = [
        APP / "Info.plist",
        APP / "Stillway.entitlements",
    ]
    extra_widget = [
        WIDGETS / "Info.plist",
        WIDGETS / "StillwayWidgets.entitlements",
    ]

    file_ref_lines: list[str] = []
    build_file_lines: list[str] = []
    app_source_bfs: list[str] = []
    widget_source_bfs: list[str] = []
    resource_bfs: list[str] = []
    refs: dict[pathlib.Path, str] = {}

    def add_file_ref(path: pathlib.Path, explicit: str | None = None) -> str:
        ref = nid(f"REF:{path.relative_to(ROOT).as_posix()}")
        refs[path] = ref
        ftype = explicit or file_type(path)
        file_ref_lines.append(
            f"\t\t{ref} /* {path.name} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = {path.name}; sourceTree = \"<group>\"; }};"
        )
        return ref

    for path in app_swifts:
        ref = add_file_ref(path)
        bf = nid(f"BF:{path.relative_to(ROOT).as_posix()}")
        build_file_lines.append(
            f"\t\t{bf} /* {path.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref} /* {path.name} */; }};"
        )
        app_source_bfs.append(f"\t\t\t\t{bf} /* {path.name} in Sources */,")

    for path in widget_swifts:
        ref = add_file_ref(path)
        bf = nid(f"BF:{path.relative_to(ROOT).as_posix()}")
        build_file_lines.append(
            f"\t\t{bf} /* {path.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref} /* {path.name} */; }};"
        )
        widget_source_bfs.append(f"\t\t\t\t{bf} /* {path.name} in Sources */,")

    for path in resources:
        ref = add_file_ref(path)
        bf = nid(f"BF:{path.relative_to(ROOT).as_posix()}")
        build_file_lines.append(
            f"\t\t{bf} /* {path.name} in Resources */ = {{isa = PBXBuildFile; fileRef = {ref} /* {path.name} */; }};"
        )
        resource_bfs.append(f"\t\t\t\t{bf} /* {path.name} in Resources */,")

    for path in extra_app + extra_widget:
        add_file_ref(path)

    app_product = nid("PRODUCT_APP")
    widget_product = nid("PRODUCT_WIDGET")
    file_ref_lines.append(
        f"\t\t{app_product} /* Stillway.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Stillway.app; sourceTree = BUILT_PRODUCTS_DIR; }};"
    )
    file_ref_lines.append(
        f"\t\t{widget_product} /* StillwayWidgets.appex */ = {{isa = PBXFileReference; explicitFileType = \"wrapper.app-extension\"; includeInIndex = 0; path = StillwayWidgets.appex; sourceTree = BUILT_PRODUCTS_DIR; }};"
    )

    package_product = nid("PKGPROD_GRDB")
    package_ref = nid("PKG_GRDB")
    package_build = nid("PKGBUILD_GRDB")
    widget_embed_bf = nid("BF_EMBED_WIDGET")
    build_file_lines.append(
        f"\t\t{package_build} /* GRDB in Frameworks */ = {{isa = PBXBuildFile; productRef = {package_product} /* GRDB */; }};"
    )
    build_file_lines.append(
        f"\t\t{widget_embed_bf} /* StillwayWidgets.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {widget_product} /* StillwayWidgets.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};"
    )

    # Nested groups for Stillway/
    group_lines: list[str] = []
    folders: dict[pathlib.Path, list[str]] = {}

    def ensure_folder(folder: pathlib.Path) -> None:
        folders.setdefault(folder, [])
        if folder not in (APP, WIDGETS) and folder.parent not in (ROOT,):
            ensure_folder(folder.parent)
            gid = nid(f"GROUP:{folder.relative_to(ROOT).as_posix()}")
            parent_kids = folders.setdefault(folder.parent, [])
            token = f"{gid} /* {folder.name} */"
            if token not in parent_kids:
                parent_kids.append(token)

    for path in app_swifts + extra_app + resources:
        ensure_folder(path.parent)
        folders.setdefault(path.parent, []).append(f"{refs[path]} /* {path.name} */")
        if path.parent != APP:
            ensure_folder(path.parent)

    for path in widget_swifts + extra_widget:
        folders.setdefault(path.parent, []).append(f"{refs[path]} /* {path.name} */")

    for folder, children in folders.items():
        gid = nid(f"GROUP:{folder.relative_to(ROOT).as_posix()}")
        child_txt = "".join(f"\n\t\t\t\t{c}," for c in children)
        group_lines.append(
            f"\t\t{gid} /* {folder.name} */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ({child_txt}\n\t\t\t);\n\t\t\tpath = {folder.name};\n\t\t\tsourceTree = \"<group>\";\n\t\t}};"
        )

    group_root = nid("GROUP_ROOT")
    group_products = nid("GROUP_PRODUCTS")
    app_group = nid(f"GROUP:{APP.relative_to(ROOT).as_posix()}")
    widget_group = nid(f"GROUP:{WIDGETS.relative_to(ROOT).as_posix()}")

    group_lines.append(
        f"""\t\t{group_products} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{app_product} /* Stillway.app */,
				{widget_product} /* StillwayWidgets.appex */,
			);
			name = Products;
			sourceTree = "<group>";
		}};"""
    )
    group_lines.append(
        f"""\t\t{group_root} = {{
			isa = PBXGroup;
			children = (
				{app_group} /* Stillway */,
				{widget_group} /* StillwayWidgets */,
				{group_products} /* Products */,
			);
			sourceTree = "<group>";
		}};"""
    )

    app_target = nid("TARGET_APP")
    widget_target = nid("TARGET_WIDGET")
    project_id = nid("PROJECT")
    app_sources = nid("PHASE_APP_SOURCES")
    app_resources = nid("PHASE_APP_RESOURCES")
    app_frameworks = nid("PHASE_APP_FRAMEWORKS")
    widget_sources = nid("PHASE_WIDGET_SOURCES")
    widget_resources = nid("PHASE_WIDGET_RESOURCES")
    widget_frameworks = nid("PHASE_WIDGET_FRAMEWORKS")
    embed = nid("PHASE_EMBED")
    dep = nid("DEP_WIDGET")
    proxy = nid("PROXY_WIDGET")
    cl_app = nid("CL_APP")
    cl_widget = nid("CL_WIDGET")
    cl_proj = nid("CL_PROJECT")
    cfg_app_d = nid("CFG_APP_D")
    cfg_app_r = nid("CFG_APP_R")
    cfg_wid_d = nid("CFG_WID_D")
    cfg_wid_r = nid("CFG_WID_R")
    cfg_prj_d = nid("CFG_PRJ_D")
    cfg_prj_r = nid("CFG_PRJ_R")

    pbx = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_file_lines)}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
		{proxy} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = {project_id} /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {widget_target};
			remoteInfo = StillwayWidgets;
		}};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
		{embed} /* Embed Foundation Extensions */ = {{
			isa = PBXCopyFilesBuildPhase;
			buildActionMask = 2147483647;
			dstPath = "";
			dstSubfolderSpec = 13;
			files = (
				{widget_embed_bf} /* StillwayWidgets.appex in Embed Foundation Extensions */,
			);
			name = "Embed Foundation Extensions";
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
{chr(10).join(file_ref_lines)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{app_frameworks} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{package_build} /* GRDB in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{widget_frameworks} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
 mar			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{chr(10).join(group_lines)}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{app_target} /* Stillway */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {cl_app} /* Build configuration list for PBXNativeTarget "Stillway" */;
			buildPhases = (
				{app_sources} /* Sources */,
				{app_frameworks} /* Frameworks */,
				{app_resources} /* Resources */,
				{embed} /* Embed Foundation Extensions */,
			);
			buildRules = (
			);
			dependencies = (
				{dep} /* PBXTargetDependency */,
			);
			name = Stillway;
			packageProductDependencies = (
				{package_product} /* GRDB */,
			);
 mar			productName = Stillway;
			productReference = {app_product} /* Stillway.app */;
			productType = "com.apple.product-type.application";
		}};
		{widget_target} /* StillwayWidgets */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {cl_widget} /* Build configuration list for PBXNativeTarget "StillwayWidgets" */;
			buildPhases = (
				{widget_sources} /* Sources */,
				{widget_frameworks} /* Frameworks */,
				{widget_resources} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = StillwayWidgets;
			productName = StillwayWidgets;
			productReference = {widget_product} /* StillwayWidgets.appex */;
			productType = "com.apple.product-type.app-extension";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{project_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1600;
				LastUpgradeCheck = 1600;
			}};
			buildConfigurationList = {cl_proj} /* Build configuration list for PBXProject "Stillway" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
				tr,
				ja,
				fr,
			);
			mainGroup = {group_root};
			packageReferences = (
				{package_ref} /* XCRemoteSwiftPackageReference "GRDB.swift" */,
			);
			productRefGroup = {group_products};
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{app_target} /* Stillway */,
				{widget_target} /* StillwayWidgets */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{app_resources} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{chr(10).join(resource_bfs)}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{widget_resources} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{app_sources} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{chr(10).join(app_source_bfs)}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{widget_sources} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{chr(10).join(widget_source_bfs)}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
		{dep} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {widget_target} /* StillwayWidgets */;
			targetProxy = {proxy} /* PBXContainerItemProxy */;
		}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
		{cfg_prj_d} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.10;
			}};
			name = Debug;
		}};
		{cfg_prj_r} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.10;
			}};
			name = Release;
		}};
		{cfg_app_d} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Stillway/Stillway.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Stillway/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Stillway;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.lifestyle";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UIUserInterfaceStyle = Dark;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stillway.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_STRICT_CONCURRENCY = targeted;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{cfg_app_r} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Stillway/Stillway.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Stillway/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Stillway;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.lifestyle";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UIUserInterfaceStyle = Dark;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stillway.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_STRICT_CONCURRENCY = targeted;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
		{cfg_wid_d} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				CODE_SIGN_ENTITLEMENTS = StillwayWidgets/StillwayWidgets.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = StillwayWidgets/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Stillway;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks";
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stillway.app.widgets;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{cfg_wid_r} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				CODE_SIGN_ENTITLEMENTS = StillwayWidgets/StillwayWidgets.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = StillwayWidgets/Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = Stillway;
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks";
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stillway.app.widgets;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SKIP_INSTALL = YES;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{cl_proj} /* Build configuration list for PBXProject "Stillway" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{cfg_prj_d} /* Debug */,
				{cfg_prj_r} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{cl_app} /* Build configuration list for PBXNativeTarget "Stillway" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{cfg_app_d} /* Debug */,
				{cfg_app_r} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{cl_widget} /* Build configuration list for PBXNativeTarget "StillwayWidgets" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{cfg_wid_d} /* Debug */,
				{cfg_wid_r} /* Release */,
 mar			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */

/* Begin XCRemoteSwiftPackageReference section */
		{package_ref} /* XCRemoteSwiftPackageReference "GRDB.swift" */ = {{
			isa = XCRemoteSwiftPackageReference;
			repositoryURL = "https://github.com/groue/GRDB.swift";
			requirement = {{
				kind = upToNextMajorVersion;
				minimumVersion = 6.29.0;
			}};
		}};
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		{package_product} /* GRDB */ = {{
			isa = XCSwiftPackageProductDependency;
			package = {package_ref} /* XCRemoteSwiftPackageReference "GRDB.swift" */;
			productName = GRDB;
		}};
/* End XCSwiftPackageProductDependency section */
	}};
	rootObject = {project_id} /* Project object */;
}}
"""
    pbx = pbx.replace(" mar", "")
    out = ROOT / "Stillway.xcodeproj" / "project.pbxproj"
    out.write_text(pbx, encoding="utf-8")
    print(f"pbxproj: {len(app_swifts)} app + {len(widget_swifts)} widget sources")


def write_scheme() -> None:
    scheme_dir = ROOT / "Stillway.xcodeproj" / "xcshareddata" / "xcschemes"
    scheme_dir.mkdir(parents=True, exist_ok=True)
    (scheme_dir / "Stillway.xcscheme").write_text(
        """<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "NEED"
               BuildableName = "Stillway.app"
               BlueprintName = "Stillway"
               ReferencedContainer = "container:Stillway.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "NEED"
            BuildableName = "Stillway.app"
            BlueprintName = "Stillway"
            ReferencedContainer = "container:Stillway.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "NEED"
            BuildableName = "Stillway.app"
            BlueprintName = "Stillway"
            ReferencedContainer = "container:Stillway.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
""",
        encoding="utf-8",
    )


def main() -> None:
    write_assets()
    write_xcstrings()
    write_json(APP / "Resources" / "stations.json", SAMPLE_STATIONS)
    generate_pbxproj()
    write_scheme()
    (APP / "Resources" / "Sounds" / ".gitkeep").write_text("", encoding="utf-8")


if __name__ == "__main__":
    main()
