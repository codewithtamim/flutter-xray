#!/usr/bin/env python3
"""
Build script for flutter_xray plugin.

This script:
  1. Builds libXray.aar for Android using gomobile.
  2. Builds LibXray.xcframework for iOS/macOS using gomobile.
  3. Copies the artifacts into the native plugin directories.
  4. Patches native build files to reference the artifacts.

Usage:
  python3 scripts/build_and_wire.py [android|apple|all]

Defaults to "all" if no argument is given.
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


def main():
    platform = sys.argv[1] if len(sys.argv) > 1 else "all"
    if platform not in ("android", "apple", "all"):
        print(f"Unknown platform: {platform}")
        print("Usage: python3 scripts/build_and_wire.py [android|apple|all]")
        sys.exit(1)

    print(f"Project root: {PROJECT_ROOT}")
    print(f"libXray dir: {LIBXRAY_DIR}")
    print(f"Target platform: {platform}")

    clean_old_artifacts()

    if platform in ("android", "all"):
        build_android()
        wire_android()

    if platform in ("apple", "all"):
        build_apple()
        wire_ios()
        wire_macos()

    print("\n=== Done ===")
    print("Next steps:")
    print("  - Android: gradle sync and build")
    print("  - iOS:     cd ios && pod install")
    print("  - macOS:   cd macos && pod install")


if __name__ == "__main__":
    main()
