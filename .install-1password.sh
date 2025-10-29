#!/bin/bash

set -e

# Exit early if 1Password CLI is already installed
if command -v op &> /dev/null; then
    exit 0
fi

echo "🔐 Installing 1Password CLI..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
    Darwin)
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo "⚠️  Homebrew is not installed. Please install it first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi

        # Install 1Password CLI via Homebrew
        brew install --cask 1password-cli
        echo "✅ 1Password CLI installed successfully"
        ;;
    Linux)
        echo "⚠️  Linux installation not yet configured. Please install manually:"
        echo "  https://developer.1password.com/docs/cli/get-started/#install"
        exit 1
        ;;
    *)
        echo "⚠️  Unsupported operating system: $OS"
        exit 1
        ;;
esac
