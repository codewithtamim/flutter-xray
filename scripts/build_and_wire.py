#!/usr/bin/env python3
"""
Build script for flutter_xray plugin.

This script:
  1. Builds libXray.aar for Android using gomobile.
  2. Builds LibXray.xcframework for iOS/macOS using gomobile.
  3. Copies the artifacts into the native plugin directories.
  4. Patches native build files to reference the artifacts.

Usage:
  python3 scripts/build_and_wire.py
"""

import os
import shutil
import subprocess
import sys


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))

LIBXRAY_DIR = os.path.join(PROJECT_ROOT, "libXray")
BUILD_SCRIPT = os.path.join(LIBXRAY_DIR, "build", "main.py")

ANDROID_LIBS_DIR = os.path.join(PROJECT_ROOT, "android", "libs")
IOS_DIR = os.path.join(PROJECT_ROOT, "ios")
MACOS_DIR = os.path.join(PROJECT_ROOT, "macos")

AAR_NAME = "libXray.aar"
XCFRAMEWORK_NAME = "LibXray.xcframework"


def run(cmd, cwd=None, check=True):
    print(f"$ {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd, capture_output=False, text=True)
    if check and result.returncode != 0:
        raise RuntimeError(f"Command failed: {' '.join(cmd)}")
    return result


def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)


def clean_old_artifacts():
    """Remove previously copied artifacts so we don't have stale files."""
    aar_dst = os.path.join(ANDROID_LIBS_DIR, AAR_NAME)
    if os.path.exists(aar_dst):
        print(f"Removing old {aar_dst}")
        os.remove(aar_dst)

    ios_xc = os.path.join(IOS_DIR, XCFRAMEWORK_NAME)
    if os.path.exists(ios_xc):
        print(f"Removing old {ios_xc}")
        shutil.rmtree(ios_xc)

    macos_xc = os.path.join(MACOS_DIR, XCFRAMEWORK_NAME)
    if os.path.exists(macos_xc):
        print(f"Removing old {macos_xc}")
        shutil.rmtree(macos_xc)


def build_android():
    print("\n=== Building Android AAR ===")
    run([sys.executable, BUILD_SCRIPT, "android"], cwd=LIBXRAY_DIR)


def build_apple():
    print("\n=== Building Apple xcframework ===")
    run([sys.executable, BUILD_SCRIPT, "apple", "gomobile"], cwd=LIBXRAY_DIR)


def wire_android():
    print("\n=== Wiring Android AAR ===")
    ensure_dir(ANDROID_LIBS_DIR)
    src = os.path.join(LIBXRAY_DIR, AAR_NAME)
    dst = os.path.join(ANDROID_LIBS_DIR, AAR_NAME)
    if not os.path.exists(src):
        raise FileNotFoundError(f"Android AAR not found at {src}")
    shutil.copy2(src, dst)
    print(f"Copied {src} -> {dst}")


def wire_ios():
    print("\n=== Wiring iOS xcframework ===")
    src = os.path.join(LIBXRAY_DIR, XCFRAMEWORK_NAME)
    dst = os.path.join(IOS_DIR, XCFRAMEWORK_NAME)
    if not os.path.exists(src):
        raise FileNotFoundError(f"iOS xcframework not found at {src}")
    shutil.copytree(src, dst, dirs_exist_ok=True)
    print(f"Copied {src} -> {dst}")


def wire_macos():
    print("\n=== Wiring macOS xcframework ===")
    src = os.path.join(LIBXRAY_DIR, XCFRAMEWORK_NAME)
    dst = os.path.join(MACOS_DIR, XCFRAMEWORK_NAME)
    if not os.path.exists(src):
        raise FileNotFoundError(f"macOS xcframework not found at {src}")
    shutil.copytree(src, dst, dirs_exist_ok=True)
    print(f"Copied {src} -> {dst}")


def patch_android_build_gradle():
    """Ensure android/build.gradle.kts references the local AAR."""
    gradle_path = os.path.join(PROJECT_ROOT, "android", "build.gradle.kts")
    with open(gradle_path, "r") as f:
        content = f.read()

    changes = []

    if "flatDir" not in content:
        old = """allprojects {
    repositories {
        google()
        mavenCentral()
    }
}"""
        new = """allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("libs")
        }
    }
}"""
        if old in content:
            content = content.replace(old, new)
            changes.append("Added flatDir repository")

    aar_dep = 'implementation(name = "libXray", ext = "aar")'
    if aar_dep not in content:
        # Add near the existing dependencies block
        old_dep = """dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}"""
        new_dep = """dependencies {
    implementation(name = "libXray", ext = "aar")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}"""
        if old_dep in content:
            content = content.replace(old_dep, new_dep)
            changes.append("Added libXray AAR dependency")

    if changes:
        with open(gradle_path, "w") as f:
            f.write(content)
        print(f"Patched {gradle_path}: {', '.join(changes)}")
    else:
        print(f"No changes needed for {gradle_path}")


def patch_ios_podspec():
    """Ensure iOS podspec references the vendored xcframework."""
    podspec_path = os.path.join(IOS_DIR, "flutter_xray.podspec")
    with open(podspec_path, "r") as f:
        content = f.read()

    changes = []
    vendored_line = "s.vendored_frameworks = 'LibXray.xcframework'"

    if vendored_line not in content:

        lines = content.splitlines()
        for i in range(len(lines) - 1, -1, -1):
            if lines[i].strip() == "end":
                lines.insert(i, f"  {vendored_line}")
                break
        content = "\n".join(lines) + "\n"
        changes.append("Added vendored_frameworks")

    if "s.platform = :ios, '15.0'" not in content:
        content = content.replace("s.platform = :ios, '13.0'", "s.platform = :ios, '15.0'")
        changes.append("Updated minimum iOS version to 15.0")

    if changes:
        with open(podspec_path, "w") as f:
            f.write(content)
        print(f"Patched {podspec_path}: {', '.join(changes)}")
    else:
        print(f"No changes needed for {podspec_path}")


def patch_macos_podspec():
    """Ensure macOS podspec references the vendored xcframework."""
    podspec_path = os.path.join(MACOS_DIR, "flutter_xray.podspec")
    with open(podspec_path, "r") as f:
        content = f.read()

    changes = []
    vendored_line = "s.vendored_frameworks = 'LibXray.xcframework'"

    if vendored_line not in content:
        lines = content.splitlines()
        for i in range(len(lines) - 1, -1, -1):
            if lines[i].strip() == "end":
                lines.insert(i, f"  {vendored_line}")
                break
        content = "\n".join(lines) + "\n"
        changes.append("Added vendored_frameworks")

    
    if "s.platform = :osx, '11.0'" not in content:
        content = content.replace("s.platform = :osx, '10.11'", "s.platform = :osx, '11.0'")
        changes.append("Updated minimum macOS version to 11.0")

    if changes:
        with open(podspec_path, "w") as f:
            f.write(content)
        print(f"Patched {podspec_path}: {', '.join(changes)}")
    else:
        print(f"No changes needed for {podspec_path}")


def main():
    print(f"Project root: {PROJECT_ROOT}")
    print(f"libXray dir: {LIBXRAY_DIR}")

    clean_old_artifacts()

    # Build
    build_android()
    build_apple()

   
    wire_android()
    wire_ios()
    wire_macos()

    # Patch build configs
    patch_android_build_gradle()
    patch_ios_podspec()
    patch_macos_podspec()

    print("\n=== Done ===")
    print("Next steps:")
    print("  - Android: gradle sync and build")
    print("  - iOS:     cd ios && pod install")
    print("  - macOS:   cd macos && pod install")


if __name__ == "__main__":
    main()
