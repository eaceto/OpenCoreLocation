# OpenCoreLocation Makefile
# Provides convenient commands for development tasks

.PHONY: build test clean docs help install-deps examples run-background run-region-example run-utils-example run-filter-example run-accuracy-example run-fallback-test run-quick-fallback run-ip-test

# Default target
help:
	@echo "🚀 OpenCoreLocation Development Commands"
	@echo "======================================"
	@echo ""
	@echo "Building:"
	@echo "  build      - Build the project"
	@echo "  test       - Run all tests"
	@echo "  clean      - Clean build artifacts"
	@echo ""
	@echo "Documentation:"
	@echo "  docs       - Generate API documentation"
	@echo "  docs-open  - Generate docs and open in browser"
	@echo ""
	@echo "Development:"
	@echo "  install-deps - Install development dependencies"
	@echo "  format     - Format code (if swiftformat is available)"
	@echo "  lint       - Lint code (if swiftlint is available)"
	@echo ""
	@echo "Examples:"
	@echo "  examples              - List available example files"
	@echo "  run-background        - Run background location updates example"
	@echo "  run-region-example    - Run region monitoring example"
	@echo "  run-utils-example     - Run location utilities example" 
	@echo "  run-filter-example    - Run distance filter example"
	@echo "  run-accuracy-example  - Run accuracy demonstration"
	@echo "  run-fallback-test     - Run provider fallback test"
	@echo "  run-quick-fallback    - Run simple fallback verification"
	@echo "  run-ip-test           - Run IP geolocation test"
	@echo ""

# Build the project
build:
	@echo "🔨 Building OpenCoreLocation..."
	swift build

# Run tests
test:
	@echo "🧪 Running tests..."
	swift test

# Run specific test suite
test-location:
	@echo "🧪 Running location manager tests..."
	swift test --filter CLLocationManagerTests

test-utils:
	@echo "🧪 Running utils tests..."
	swift test --filter CLLocationUtilsTests

test-regions:
	@echo "🧪 Running region tests..."
	swift test --filter CLCircularRegionTests

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	rm -rf docs

# Generate documentation
docs:
	@echo "📚 Generating API documentation..."
	./scripts/generate-docs.sh

# Generate docs and open in browser
docs-open: docs
	@echo "🌐 Opening documentation in browser..."
	open docs/index.html

# Install development dependencies
install-deps:
	@echo "📦 Installing development dependencies..."
	@if command -v gem >/dev/null 2>&1; then \
		echo "Installing Jazzy for documentation generation..."; \
		gem install jazzy; \
	else \
		echo "❌ gem not found. Please install Ruby first."; \
		exit 1; \
	fi

# Format code (if swiftformat is available)
format:
	@if command -v swiftformat >/dev/null 2>&1; then \
		echo "🎨 Formatting Swift code..."; \
		swiftformat Sources Tests; \
	else \
		echo "⚠️  swiftformat not found. Install with: brew install swiftformat"; \
	fi

# Lint code (if swiftlint is available)  
lint:
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "🔍 Linting Swift code..."; \
		swiftlint; \
	else \
		echo "⚠️  swiftlint not found. Install with: brew install swiftlint"; \
	fi

# List example files
examples:
	@echo "📘 Available Examples:"
	@echo "====================="
	@echo ""
	@echo "1. BackgroundLocationExample"
	@echo "   - Demonstrates background location updates with automatic pausing"
	@echo "   - Run: swift run BackgroundLocationExample"
	@echo ""
	@echo "2. RegionMonitoringExample"
	@echo "   - Shows how to monitor geographic regions"
	@echo "   - Run: swift run RegionMonitoringExample"
	@echo ""
	@echo "3. LocationAccuracyExample"
	@echo "   - Demonstrates different accuracy levels and providers"
	@echo "   - Run: swift run LocationAccuracyExample"
	@echo ""
	@echo "4. DistanceFilterDemo"
	@echo "   - Shows how distance filtering works"
	@echo "   - Run: swift run DistanceFilterDemo"
	@echo ""
	@echo "5. LocationUtilsDemo"
	@echo "   - Demonstrates utility functions (distance, bearing)"
	@echo "   - Run: swift run LocationUtilsDemo"
	@echo ""
	@echo "6. ProviderFallbackTest"
	@echo "   - Tests automatic provider fallback mechanism"
	@echo "   - Run: swift run ProviderFallbackTest"
	@echo ""
	@echo "7. QuickFallbackTest"
	@echo "   - Quick verification of provider fallback"
	@echo "   - Run: swift run QuickFallbackTest"
	@echo ""
	@echo "8. SimpleIPTest"
	@echo "   - Tests IP-based geolocation"
	@echo "   - Run: swift run SimpleIPTest"

# Run individual examples
run-background:
	@echo "🌍 Running background location updates example..."
	swift run BackgroundLocationExample

run-region-example:
	@echo "🎯 Running region monitoring example..."
	swift run RegionMonitoringExample

run-utils-example:
	@echo "🔧 Running location utilities example..."
	swift run LocationUtilsDemo

run-filter-example:
	@echo "📏 Running distance filter example..."
	swift run DistanceFilterDemo

run-accuracy-example:
	@echo "🎯 Running accuracy example..."
	swift run LocationAccuracyExample

run-fallback-test:
	@echo "🔄 Running provider fallback test..."
	swift run ProviderFallbackTest

run-quick-fallback:
	@echo "⚡ Running quick fallback verification..."
	swift run QuickFallbackTest

run-ip-test:
	@echo "🌐 Running IP geolocation test..."
	swift run SimpleIPTest

# Development workflow
dev: clean build test docs
	@echo "✅ Development workflow completed successfully!"

# CI/CD simulation
ci: build test
	@echo "✅ CI checks passed!"

# Release preparation
release-prep: clean build test docs lint
	@echo "🚀 Release preparation completed!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Review generated documentation"
	@echo "  2. Update version numbers if needed"
	@echo "  3. Create git tag: git tag v1.2.0"
	@echo "  4. Push changes: git push && git push --tags"