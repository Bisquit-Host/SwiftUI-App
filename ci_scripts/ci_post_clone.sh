#!/bin/sh
set -eu

if [ "${CI_XCODE_CLOUD:-}" = "TRUE" ]; then
    # Allow package build plugins such as SwiftTermBuildInfoPlugin on Cloud workers
    # Validatation is the spelling required by Xcode's preference key
    defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
fi
