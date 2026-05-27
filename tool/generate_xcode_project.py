#!/usr/bin/env python3
import hashlib
import json
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "PulsePanel.xcodeproj"
PBXPROJ = PROJECT_DIR / "project.pbxproj"
TEAM_ID = "4P293R4B47"


def uid(key: str) -> str:
    return hashlib.sha1(key.encode("utf-8")).hexdigest().upper()[:24]


def q(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    if all(c.isalnum() or c in "._-$/" for c in value):
        return value
    return f'"{escaped}"'


def png_chunk(kind: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def write_png(path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    for y in range(size):
        row = bytearray()
        for x in range(size):
            t = x / max(size - 1, 1)
            u = y / max(size - 1, 1)
            row.extend((
                int(13 + 235 * t),
                int(148 - 35 * u),
                int(136 - 55 * t),
                255,
            ))
        rows.append(b"\x00" + bytes(row))
    raw = b"".join(rows)
    data = (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
        + png_chunk(b"IDAT", zlib.compress(raw, 9))
        + png_chunk(b"IEND", b"")
    )
    path.write_bytes(data)


def write_assets(base: Path, idiom: str) -> None:
    asset_dir = base / "AppIcon.appiconset"
    asset_dir.mkdir(parents=True, exist_ok=True)
    entries = []
    if idiom == "ios":
        specs = [
            ("20x20", "2x", 40), ("20x20", "3x", 60),
            ("29x29", "2x", 58), ("29x29", "3x", 87),
            ("40x40", "2x", 80), ("40x40", "3x", 120),
            ("60x60", "2x", 120), ("60x60", "3x", 180),
            ("1024x1024", "1x", 1024),
        ]
        for size, scale, pixels in specs:
            filename = f"AppIcon-{pixels}.png"
            write_png(asset_dir / filename, pixels)
            entries.append({"idiom": "iphone" if size != "1024x1024" else "ios-marketing", "size": size, "scale": scale, "filename": filename})
    else:
        specs = [
            ("16x16", "1x", 16), ("16x16", "2x", 32),
            ("32x32", "1x", 32), ("32x32", "2x", 64),
            ("128x128", "1x", 128), ("128x128", "2x", 256),
            ("256x256", "1x", 256), ("256x256", "2x", 512),
            ("512x512", "1x", 512), ("512x512", "2x", 1024),
        ]
        for size, scale, pixels in specs:
            filename = f"MacIcon-{pixels}-{scale}.png"
            write_png(asset_dir / filename, pixels)
            entries.append({"idiom": "mac", "size": size, "scale": scale, "filename": filename})
    (asset_dir / "Contents.json").write_text(json.dumps({"images": entries, "info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
    (base / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")


def file_type(path: str) -> str:
    if path.endswith(".swift"):
        return "sourcecode.swift"
    if path.endswith(".plist"):
        return "text.plist.xml"
    if path.endswith(".xcstrings"):
        return "text.json.xcstrings"
    if path.endswith(".xcassets"):
        return "folder.assetcatalog"
    return "text"


def collect_sources(path: str) -> list[str]:
    return sorted(str(p.relative_to(ROOT)) for p in (ROOT / path).rglob("*.swift"))


def build_project() -> str:
    ios_sources = collect_sources("Apps/PulsePaneliOS")
    mac_sources = collect_sources("Apps/PulsePanelMac")
    ios_resources = ["Apps/PulsePaneliOS/Resources/Localizable.xcstrings", "Apps/PulsePaneliOS/Assets.xcassets"]
    mac_resources = ["Apps/PulsePanelMac/Resources/Localizable.xcstrings", "Apps/PulsePanelMac/Assets.xcassets"]
    config_files = ["Config/PulsePaneliOS-Info.plist", "Config/PulsePanelMac-Info.plist"]

    objects: dict[str, str] = {}

    def add(object_id: str, body: str) -> str:
        objects[object_id] = body
        return object_id

    package_ref = add(uid("package:protocol"), "isa = XCLocalSwiftPackageReference; relativePath = Packages/PulsePanelProtocol;")
    package_product = add(uid("packageproduct:protocol"), f"isa = XCSwiftPackageProductDependency; package = {package_ref}; productName = PulsePanelProtocol;")
    protocol_framework_build = add(uid("build:packageproduct:protocol"), f"isa = PBXBuildFile; productRef = {package_product};")

    file_refs = {}
    all_files = ios_sources + mac_sources + ios_resources + mac_resources + config_files + ["Package.swift", "README.md", "PRODUCT.md", "DESIGN.md"]
    for path in all_files:
        file_refs[path] = add(
            uid(f"fileref:{path}"),
            f"isa = PBXFileReference; lastKnownFileType = {file_type(path)}; path = {q(path)}; sourceTree = \"<group>\";"
        )

    product_ios = add(uid("product:ios"), "isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = PulsePanel.app; sourceTree = BUILT_PRODUCTS_DIR;")
    product_mac = add(uid("product:mac"), "isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = PulsePanelMac.app; sourceTree = BUILT_PRODUCTS_DIR;")

    def build_files(paths: list[str], kind: str) -> list[str]:
        ids = []
        for path in paths:
            ids.append(add(uid(f"build:{kind}:{path}"), f"isa = PBXBuildFile; fileRef = {file_refs[path]};"))
        return ids

    ios_source_builds = build_files(ios_sources, "ios-source")
    mac_source_builds = build_files(mac_sources, "mac-source")
    ios_resource_builds = build_files(ios_resources, "ios-resource")
    mac_resource_builds = build_files(mac_resources, "mac-resource")

    def phase(name: str, isa: str, files: list[str]) -> str:
        return add(uid(f"phase:{name}"), f"""isa = {isa};
			buildActionMask = 2147483647;
			files = (
				{chr(10).join(files)}
			);
			runOnlyForDeploymentPostprocessing = 0;""")

    ios_sources_phase = phase("ios-sources", "PBXSourcesBuildPhase", [f"{x}," for x in ios_source_builds])
    mac_sources_phase = phase("mac-sources", "PBXSourcesBuildPhase", [f"{x}," for x in mac_source_builds])
    ios_resources_phase = phase("ios-resources", "PBXResourcesBuildPhase", [f"{x}," for x in ios_resource_builds])
    mac_resources_phase = phase("mac-resources", "PBXResourcesBuildPhase", [f"{x}," for x in mac_resource_builds])
    ios_frameworks_phase = phase("ios-frameworks", "PBXFrameworksBuildPhase", [f"{protocol_framework_build},"])
    mac_frameworks_phase = phase("mac-frameworks", "PBXFrameworksBuildPhase", [f"{protocol_framework_build},"])

    products_group = add(uid("group:products"), f"""isa = PBXGroup;
			children = (
				{product_ios},
				{product_mac},
			);
			name = Products;
			sourceTree = \"<group>\";""")
    main_group = add(uid("group:main"), f"""isa = PBXGroup;
			children = (
				{products_group},
				{chr(10).join(f'{file_refs[p]},' for p in all_files)}
			);
			sourceTree = \"<group>\";""")

    project_debug = add(uid("config:project:debug"), """isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				DEVELOPMENT_LANGUAGE = en;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_NO_COMMON_BLOCKS = YES;
				SWIFT_VERSION = 6.0;
			};
			name = Debug;""")
    project_release = add(uid("config:project:release"), """isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				DEVELOPMENT_LANGUAGE = en;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_NO_COMMON_BLOCKS = YES;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 6.0;
			};
			name = Release;""")

    project_config_list = add(uid("configlist:project"), f"""isa = XCConfigurationList;
			buildConfigurations = (
				{project_debug},
				{project_release},
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;""")

    def target_config(target: str, config: str, platform: str) -> str:
        is_ios = platform == "ios"
        settings = {
            "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
            "CODE_SIGN_STYLE": "Automatic",
            "CURRENT_PROJECT_VERSION": "1",
            "DEVELOPMENT_ASSET_PATHS": "\"\"",
            "DEVELOPMENT_TEAM": TEAM_ID,
            "ENABLE_PREVIEWS": "YES",
            "GENERATE_INFOPLIST_FILE": "NO",
            "INFOPLIST_FILE": "Config/PulsePaneliOS-Info.plist" if is_ios else "Config/PulsePanelMac-Info.plist",
            "LD_RUNPATH_SEARCH_PATHS": "\"$(inherited) @executable_path/Frameworks\"",
            "MARKETING_VERSION": "0.1.0",
            "PRODUCT_NAME": "PulsePanel" if is_ios else "PulsePanelMac",
            "SWIFT_EMIT_LOC_STRINGS": "YES",
            "SWIFT_VERSION": "6.0",
        }
        if is_ios:
            settings.update({
                "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
                "PRODUCT_BUNDLE_IDENTIFIER": "com.cagataydonmez.pulsepanel",
                "SDKROOT": "iphoneos",
                "SUPPORTED_PLATFORMS": "\"iphoneos iphonesimulator\"",
                "TARGETED_DEVICE_FAMILY": "1",
            })
        else:
            settings.update({
                "MACOSX_DEPLOYMENT_TARGET": "14.0",
                "PRODUCT_BUNDLE_IDENTIFIER": "com.cagataydonmez.pulsepanel.mac",
                "SDKROOT": "macosx",
                "SUPPORTED_PLATFORMS": "macosx",
            })
        if config == "Debug":
            settings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = "DEBUG"
            settings["ONLY_ACTIVE_ARCH"] = "YES"
        body_settings = "\n".join(f"\t\t\t\t{k} = {v};" for k, v in sorted(settings.items()))
        return add(uid(f"config:{target}:{config}"), f"""isa = XCBuildConfiguration;
			buildSettings = {{
{body_settings}
			}};
			name = {config};""")

    def target(name: str, product_ref: str, sources_phase: str, resources_phase: str, frameworks_phase: str, platform: str) -> str:
        debug = target_config(name, "Debug", platform)
        release = target_config(name, "Release", platform)
        config_list = add(uid(f"configlist:{name}"), f"""isa = XCConfigurationList;
			buildConfigurations = (
				{debug},
				{release},
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;""")
        return add(uid(f"target:{name}"), f"""isa = PBXNativeTarget;
			buildConfigurationList = {config_list};
			buildPhases = (
				{sources_phase},
				{frameworks_phase},
				{resources_phase},
			);
			buildRules = (
			);
			dependencies = (
			);
			name = {name};
			packageProductDependencies = (
				{package_product},
			);
			productName = {name};
			productReference = {product_ref};
			productType = \"com.apple.product-type.application\";""")

    ios_target = target("PulsePaneliOS", product_ios, ios_sources_phase, ios_resources_phase, ios_frameworks_phase, "ios")
    mac_target = target("PulsePanelMac", product_mac, mac_sources_phase, mac_resources_phase, mac_frameworks_phase, "mac")

    project = add(uid("project"), f"""isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 2640;
				LastUpgradeCheck = 2640;
				TargetAttributes = {{
					{ios_target} = {{ CreatedOnToolsVersion = 26.4.1; }};
					{mac_target} = {{ CreatedOnToolsVersion = 26.4.1; }};
				}};
			}};
			buildConfigurationList = {project_config_list};
			compatibilityVersion = \"Xcode 15.0\";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				tr,
				Base,
			);
			mainGroup = {main_group};
			minimizedProjectReferenceProxies = 1;
			packageReferences = (
				{package_ref},
			);
			productRefGroup = {products_group};
			projectDirPath = \"\";
			projectRoot = \"\";
			targets = (
				{ios_target},
				{mac_target},
			);""")

    sections = "\n".join(f"\t\t{object_id} = {{ {body} }};" for object_id, body in sorted(objects.items()))
    return f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{
{sections}
	}};
	rootObject = {project};
}}
"""


def write_scheme(name: str, target_id: str, buildable_name: str) -> None:
    scheme_dir = PROJECT_DIR / "xcshareddata" / "xcschemes"
    scheme_dir.mkdir(parents=True, exist_ok=True)
    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2640" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES" buildArchitectures="Automatic">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target_id}" BuildableName="{buildable_name}" BlueprintName="{name}" ReferencedContainer="container:PulsePanel.xcodeproj"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"/>
   <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target_id}" BuildableName="{buildable_name}" BlueprintName="{name}" ReferencedContainer="container:PulsePanel.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target_id}" BuildableName="{buildable_name}" BlueprintName="{name}" ReferencedContainer="container:PulsePanel.xcodeproj"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug"/>
   <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
"""
    # Xcode tolerates unknown debugger values poorly; keep the launch action valid.
    xml = xml.replace("Xcode.DebuggerFoundation.Launcher.LLLDB", "Xcode.DebuggerFoundation.Launcher.LLDB")
    (scheme_dir / f"{name}.xcscheme").write_text(xml)


def main() -> None:
    write_assets(ROOT / "Apps/PulsePaneliOS/Assets.xcassets", "ios")
    write_assets(ROOT / "Apps/PulsePanelMac/Assets.xcassets", "mac")
    PROJECT_DIR.mkdir(exist_ok=True)
    PBXPROJ.write_text(build_project())
    write_scheme("PulsePaneliOS", uid("target:PulsePaneliOS"), "PulsePanel.app")
    write_scheme("PulsePanelMac", uid("target:PulsePanelMac"), "PulsePanelMac.app")
    print(f"Generated {PBXPROJ.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
