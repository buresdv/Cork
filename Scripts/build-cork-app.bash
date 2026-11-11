#!/usr/bin/env bash
#
# This script builds Cork's "Self-Compiled" scheme using xcodebuild without opening Xcode.
#
# Version: v1.0.0
# License: MIT License
#          Copyright (c) 2026 Hunter T. (StrangeRanger)
#
############################################################################################
set -euo pipefail
####[ Global Variables ]####################################################################


readonly C_GREEN=$'\033[0;32m'
readonly C_BLUE=$'\033[0;34m'
readonly C_CYAN=$'\033[0;36m'
readonly C_RED=$'\033[1;31m'
readonly C_NC=$'\033[0m'

readonly C_ERROR="${C_RED}ERROR:${C_NC} "
readonly C_SUCC="${C_GREEN}==>${C_NC} "
readonly C_INFO="${C_BLUE}==>${C_NC} "
readonly C_NOTE="${C_CYAN}==>${C_NC} "

C_ROOT_DIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")/..")"
readonly C_ROOT_DIR
readonly C_BUILD_DIR="$C_ROOT_DIR/.build/self-compiled"
readonly C_DERIVED_DATA_DIR="$C_BUILD_DIR/DerivedData"
readonly C_SOURCE_PACKAGES_DIR="$C_BUILD_DIR/SourcePackages"
readonly C_PACKAGE_CACHE_DIR="$C_BUILD_DIR/PackageCache"
readonly C_ARCHIVE_PATH="$C_BUILD_DIR/Cork.xcarchive"
readonly C_ARCHIVED_APP="$C_ARCHIVE_PATH/Products/Applications/Cork.app"

readonly C_SCHEME="Self-Compiled"
readonly C_CONFIGURATION="Release"

install_dir="/Applications"
export_dir="$C_BUILD_DIR/export"
export_app="$export_dir/Cork.app"

run_tuist=1
clean=0
install=0
force=0
launch=0
xcodebuild_logging=(-quiet)


####[ Functions ]###########################################################################


####
# Print script usage information.
usage() {
    cat <<EOF
Builds Cork's Self-Compiled scheme without opening Xcode.

${C_BLUE}Usage: ${C_GREEN}./Scripts/build-self-compiled.sh ${C_CYAN}[options]${C_NC}

${C_BLUE}Options:${C_NC}
  ${C_CYAN}--install${C_NC}              Copy Cork.app to /Applications after building
  ${C_CYAN}--install-dir <path>${C_NC}   Copy Cork.app to a different install directory
  ${C_CYAN}--output-dir <path>${C_NC}    Copy the built Cork.app to a different output directory
  ${C_CYAN}--clean${C_NC}                Remove this script's .build/self-compiled directory first
  ${C_CYAN}--skip-tuist${C_NC}           Skip 'tuist install' and 'tuist generate'
  ${C_CYAN}--force${C_NC}                Replace an existing installed app without prompting
  ${C_CYAN}--launch${C_NC}               Open the built or installed app after the build
  ${C_CYAN}--verbose${C_NC}              Show full xcodebuild output
  ${C_CYAN}-h${C_NC}, ${C_CYAN}--help${C_NC}             Show this help message
EOF
}

####
# Print an error message and exit with a non-zero status.
std_error() {
    local message="$*"

    echo "${C_ERROR}${message}" >&2
    exit 1
}

####
# Ask the user to confirm replacing an existing app at the given path. Exits if the user
# cancels.
confirm_replace() {
    local path="$1"
    local answer

    if (( force == 1 )); then
        return 0
    fi

    printf "%s'%s' already exists. Replace it? [y/N] " "$C_INFO" "$path"
    read -r answer

    answer="${answer,,}"
    case "$answer" in
        y*) ;;
        *) std_error "install cancelled" ;;
    esac
}

####
# Guarantees that $C_BUILD_DIR is only deleted if it's under '$C_ROOT_DIR/.build'. This is a
# safety measure to prevent accidentally deleting important files if $C_BUILD_DIR is
# misconfigured.
clean_build_dir() {
    case "$C_BUILD_DIR" in
        "$C_ROOT_DIR"/.build/*)
            rm -rf "$C_BUILD_DIR"
            ;;
        *)
            std_error "INTERNAL: $C_BUILD_DIR is not under $C_ROOT_DIR/.build"
            ;;
    esac
}


####[ Argument Parsing ]####################################################################


while (( $# > 0 )); do
    case "$1" in
        --install)
            install=1
            ;;
        --install-dir)
            (( $# >= 2 )) || std_error "--install-dir requires a path"
            install_dir="$2"
            shift
            ;;
        --output-dir)
            (( $# >= 2 )) || std_error "--output-dir requires a path"
            export_dir="$2"
            export_app="$export_dir/Cork.app"
            shift
            ;;
        --clean)
            clean=1
            ;;
        --skip-tuist)
            run_tuist=0
            ;;
        --force)
            force=1
            ;;
        --launch)
            launch=1
            ;;
        --verbose)
            xcodebuild_logging=()
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            std_error "unknown option: $1"
            ;;
    esac
    shift
done

dest_app="$install_dir/Cork.app"
app_to_launch="$export_app"


####[ Pre-checks ]##########################################################################


case "$(uname -s)" in
    Darwin) ;;
    *) std_error "Cork can only be built on macOS" ;;
esac

if ! command -v xcodebuild &>/dev/null; then
    std_error "xcodebuild is required to run this script, but it was not found in PATH."
fi

if (( run_tuist == 1 )); then
    if ! command -v tuist &>/dev/null; then
        std_error "Tuist is required to run this script, but it was not found in PATH." \
            "Please install Tuist and try again, or run the script with --skip-tuist if" \
            "you have already generated the Xcode project."
    fi
fi


#####[ Main ]###############################################################################


if (( clean == 1 )); then
    echo "${C_INFO}Cleaning '$C_BUILD_DIR'..."
    clean_build_dir
fi

cd "$C_ROOT_DIR"

if (( run_tuist == 1 )); then
    echo "${C_INFO}Installing Tuist dependencies..."
    tuist install

    echo "${C_INFO}Generating Xcode project..."
    if ! tuist generate --no-open --cache-profile none; then
        echo "${C_INFO}Retrying Tuist generation with legacy cache flags..."
        tuist generate --no-open --no-binary-cache
    fi
fi

[[ -d $C_ROOT_DIR/Cork.xcworkspace ]] || std_error "Cork.xcworkspace was not generated"

echo "${C_INFO}Archiving '$C_SCHEME'..."

xcodebuild \
    "${xcodebuild_logging[@]}" \
    -workspace "$C_ROOT_DIR/Cork.xcworkspace" \
    -scheme "$C_SCHEME" \
    -configuration "$C_CONFIGURATION" \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$C_DERIVED_DATA_DIR" \
    -clonedSourcePackagesDirPath "$C_SOURCE_PACKAGES_DIR" \
    -packageCachePath "$C_PACKAGE_CACHE_DIR" \
    -archivePath "$C_ARCHIVE_PATH" \
    -skipPackagePluginValidation \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM= \
    CODE_SIGN_IDENTITY=- \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGNING_REQUIRED=YES \
    archive

[[ -d $C_ARCHIVED_APP ]] || std_error "archive did not contain Cork.app at '$C_ARCHIVED_APP'"

## Ensure export directory is empty before copying the app.
if [[ -e $export_app ]]; then
    rm -rf "$export_app"
fi

echo "${C_INFO}Copying app to '$export_app'..."
ditto "$C_ARCHIVED_APP" "$export_app"

if (( install == 1 )); then
    # Ensure the install directory exists before copying the app, especially if the user
    # specified a custom directory with --install-dir.
    mkdir -p "$install_dir"

    if [[ -e $dest_app ]]; then
        confirm_replace "$dest_app"
        rm -rf "$dest_app"
    fi

    echo "${C_INFO}Installing app to '$dest_app'..."
    ditto "$export_app" "$dest_app"
    app_to_launch="$dest_app"
fi

if (( launch == 1 )); then
    echo "${C_INFO}Launching '$app_to_launch'..."
    open "$app_to_launch"
fi

echo "${C_SUCC}Done"
echo "${C_NOTE}Built app is at: $export_app"

if (( install == 1 )); then
    echo "${C_NOTE}Installed app is at: $dest_app"
fi
