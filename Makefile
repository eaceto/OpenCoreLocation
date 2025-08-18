# OpenCoreLocation Makefile
# Provides convenient commands for development tasks

.PHONY: build test clean docs help install-deps

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
	@echo "  examples   - List available example files"
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
	@echo "📘 Available example files:"
	@echo "=========================="
	@ls -la Examples/*.swift 2>/dev/null | awk '{print "  " $$NF " - " $$5 " bytes"}' || echo "  No example files found"
	@echo ""
	@echo "Run examples by copying to your project or using swift run"

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
	@echo "  3. Create git tag: git tag v1.0.0"
	@echo "  4. Push changes: git push && git push --tags"