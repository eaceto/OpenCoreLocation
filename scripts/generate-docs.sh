#!/bin/bash

# Generate Documentation Script for OpenCoreLocation
# This script installs Jazzy (if needed) and generates comprehensive API documentation
#
# Usage:
#   ./scripts/generate-docs.sh [version]
#
# Examples:
#   ./scripts/generate-docs.sh          # Auto-detect version from git tags
#   ./scripts/generate-docs.sh 1.2.0    # Use specific version
#   ./scripts/generate-docs.sh dev      # Use 'dev' as version

set -e  # Exit on any error

echo "🚀 OpenCoreLocation Documentation Generator"
echo "==========================================="

# Check if we're in the right directory
if [[ ! -f "Package.swift" ]]; then
    echo "❌ Error: Please run this script from the OpenCoreLocation root directory"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check and install dependencies
echo "📦 Checking dependencies..."

# Check for Ruby and gem
if ! command_exists ruby || ! command_exists gem; then
    echo "❌ Error: Ruby and gem are required but not installed"
    echo "Please install Ruby first:"
    echo "  macOS: brew install ruby"
    echo "  Ubuntu: sudo apt-get install ruby-full"
    exit 1
fi

# Check for Jazzy
if ! command_exists jazzy; then
    echo "📥 Installing Jazzy..."
    if command_exists sudo; then
        sudo gem install jazzy
    else
        gem install jazzy --user-install
        echo "⚠️  Note: Jazzy installed to user directory. Make sure your PATH includes gem user install directory."
        echo "   Add this to your shell profile: export PATH=\"\$PATH:\$(gem environment | grep 'USER INSTALLATION DIRECTORY' | cut -d':' -f2)/bin\""
    fi
else
    echo "✅ Jazzy is already installed"
fi

# Verify Swift is available
if ! command_exists swift; then
    echo "❌ Error: Swift is required but not installed"
    echo "Please install Swift from https://swift.org/download/"
    exit 1
fi

echo "✅ All dependencies are ready"
echo ""

# Clean previous documentation
echo "🧹 Cleaning previous documentation..."
if [[ -d "docs" ]]; then
    rm -rf docs
fi

# Build the project first to ensure everything compiles
echo "🔨 Building project..."
swift build

# Check if build was successful
if [[ $? -ne 0 ]]; then
    echo "❌ Error: Project build failed. Please fix compilation errors first."
    exit 1
fi

echo "✅ Project built successfully"
echo ""

# Version detection - use parameter or auto-detect
echo "🔍 Determining version..."
if [[ -n "$1" ]]; then
    VERSION="$1"
    echo "   Using provided version: $VERSION"
else
    # Auto-detect version from git tags
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    if [[ -z "$VERSION" ]]; then
        # Fallback to git commit hash if no tags
        COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")
        VERSION="dev-${COMMIT_HASH}"
        echo "   No version provided or git tags found, using commit-based version: $VERSION"
    else
        echo "   No version provided, using latest git tag: $VERSION"
    fi
fi

# Generate documentation
echo "📚 Generating API documentation..."
echo "Using Jazzy configuration: .jazzy.yaml"
echo "Documentation version: $VERSION"
echo ""

# Run Jazzy with our configuration and dynamic version
if jazzy --config .jazzy.yaml --module-version "$VERSION"; then
    echo ""
    echo "🎉 Documentation generated successfully!"
    echo ""
    echo "📖 Documentation is available at:"
    echo "   File: $(pwd)/docs/index.html"
    echo "   Open with: open docs/index.html"
    echo ""
    echo "📊 Documentation Stats:"
    
    # Count documented files
    if [[ -d "docs" ]]; then
        html_files=$(find docs -name "*.html" | wc -l)
        echo "   Generated HTML files: $html_files"
        
        if [[ -f "docs/undocumented.json" ]]; then
            echo "   Undocumented items: $(jq length docs/undocumented.json 2>/dev/null || echo "N/A")"
        fi
    fi
    
    echo ""
    echo "🔗 Next Steps:"
    echo "   1. Review generated documentation: open docs/index.html"
    echo "   2. Commit documentation to git: git add docs && git commit -m 'docs: Update API documentation'"
    echo "   3. Deploy to GitHub Pages or your documentation hosting service"
    echo ""
else
    echo "❌ Error: Documentation generation failed"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   1. Check that all Swift files compile without errors"
    echo "   2. Verify .jazzy.yaml configuration is correct"
    echo "   3. Ensure all public APIs have documentation comments"
    echo "   4. Run with verbose output: jazzy --config .jazzy.yaml --verbose"
    echo ""
    exit 1
fi

echo "✨ Documentation generation complete!"