# OpenCoreLocation - Developer Documentation

This document contains development-specific information for contributors and maintainers of OpenCoreLocation.

## 🚀 Quick Start for Developers

### Development Setup

```bash
git clone https://github.com/eaceto/OpenCoreLocation.git
cd OpenCoreLocation

# Build and test
swift build
swift test

# Use convenient make commands
make help          # Show all available commands
make build         # Build the project
make test          # Run tests
make docs          # Generate documentation
make clean         # Clean build artifacts
make dev           # Full development workflow (clean + build + test + docs)
```

## 🔧 Development Tools

The project includes several convenient development tools:

- **Makefile**: Convenient build commands and development workflows
- **Documentation Generator**: Automated Jazzy documentation with GitHub Pages deployment  
- **GitHub Actions**: Automated testing and documentation deployment
- **Test Coverage**: Comprehensive test suite with >90% code coverage
- **Code Quality**: Integrated linting and formatting tools

## 🧪 Testing

### Running Tests

```bash
# Run all tests
swift test

# Run specific test suites
swift test --filter CLLocationManagerTests
swift test --filter CLLocationUtilsTests
swift test --filter CLCircularRegionTests
swift test --filter CLLocationManagerRegionMonitoringTests

# Run with verbose output
swift test --verbose
```

### Test Coverage

The project maintains >90% code coverage across:
- Core location management functionality
- Geographic utilities and calculations
- Region monitoring and geofencing
- Provider fallback systems
- Cross-platform compatibility

## 📚 Documentation Generation

### API Documentation

Comprehensive API documentation is generated using Jazzy with automatic version detection:

```bash
# Generate documentation locally
make docs

# Or use the build script directly  
./scripts/generate-docs.sh

# View documentation
open docs/index.html
```

**Version Detection**: The documentation system automatically detects and uses the latest git tag as the version number. If no tags are available, it falls back to a commit-based version (e.g., `dev-5decab3`).

**Online Documentation**: [https://eaceto.github.io/OpenCoreLocation](https://eaceto.github.io/OpenCoreLocation)

### Documentation Deployment

Documentation is automatically deployed to GitHub Pages via GitHub Actions when changes are pushed to the main branch. The workflow:

1. **Installs Dependencies**: Sets up Swift, Ruby, and Jazzy
2. **Generates Documentation**: Uses `make docs` command with automatic version detection
3. **Verifies Output**: Checks that documentation was generated successfully
4. **Deploys to GitHub Pages**: Publishes documentation to https://eaceto.github.io/OpenCoreLocation

**Workflow File**: `.github/workflows/documentation.yml`

## 🛠️ Build System & Make Commands

### Available Make Commands

```bash
# Building and Testing
make help          # Show all available commands
make build         # Build the project
make test          # Run tests
make clean         # Clean build artifacts

# Documentation
make docs          # Generate API documentation
make docs-open     # Generate docs and open in browser

# Development Workflow
make dev           # Full development workflow (clean + build + test + docs)
make ci            # CI checks (build + test)
make release-prep  # Release preparation (clean + build + test + docs + lint)

# Code Quality (if tools are installed)
make format        # Format code with swiftformat
make lint          # Lint code with swiftlint

# Dependency Management
make install-deps  # Install development dependencies
```

### Example Commands

```bash
# List available example files and commands
make examples

# Run individual examples
make run-region-example    # Run region monitoring example
make run-utils-example     # Run location utilities example  
make run-filter-example    # Run distance filter example
make run-accuracy-example  # Run accuracy demonstration
make run-fallback-test     # Run provider fallback test
make run-quick-fallback    # Run simple fallback verification
make run-ip-test          # Run IP geolocation test
```

## 📋 Example Projects for Development & Testing

### Core Functionality Examples
- **`LocationAccuracyExample.swift`**: Multi-provider accuracy system demonstration
- **`DistanceFilterDemo.swift`**: Distance filtering and battery optimization examples  
- **`LocationUtilsDemo.swift`**: Geographic utilities and calculations showcase
- **`RegionMonitoringExample.swift`**: Complete geofencing implementation with entry/exit detection

### Testing & Debugging Examples
- **`ProviderFallbackTest.swift`**: Comprehensive provider fallback behavior testing
- **`QuickFallbackTest.swift`**: Simple test for GPS → WiFi → IP fallback verification
- **`SimpleIPTest.swift`**: Direct IP geolocation provider testing

### Running Examples

```bash
# Core functionality examples
swift run LocationAccuracyExample     # Multi-provider accuracy testing
swift run DistanceFilterDemo          # Distance filtering demonstration  
swift run LocationUtilsDemo           # Geographic utilities showcase
swift run RegionMonitoringExample     # Interactive region monitoring demo

# Testing and debugging examples
swift run ProviderFallbackTest        # Provider fallback system testing
swift run QuickFallbackTest           # Simple fallback verification
swift run SimpleIPTest               # IP geolocation testing

# Or build all examples at once
swift build
```

## 🏗️ Project Architecture

### Multi-Provider System

OpenCoreLocation implements a comprehensive multi-provider architecture:

- **GPS Provider**: High-accuracy positioning via gpsd integration (1-10m accuracy)
- **WiFi Provider**: Medium-accuracy positioning using WiFi access points (40m+ accuracy)  
- **IP Provider**: Low-accuracy geolocation via IP address (1km+ accuracy)

### Provider Fallback System

The system automatically falls back through providers when higher-accuracy options fail:

```
GPS (gpsd) → WiFi → IP Geolocation
```

This ensures Apple CoreLocation-compatible behavior on Linux systems.

### Thread Safety

- **Concurrent Queues**: All location operations use concurrent dispatch queues
- **Barrier Writes**: State modifications use barrier writes for thread safety
- **Async/Await**: Modern Swift concurrency patterns throughout

## 🔍 Debugging & Troubleshooting

### Common Issues

1. **GPS Provider Failures**: Expected on systems without gpsd - fallback should work
2. **Network Timeouts**: IP/WiFi providers may timeout on slow connections
3. **Permission Issues**: Some tests may require network access permissions
4. **SPM Build Warnings**: Swift Package Manager shows warnings about "unhandled files" in the Examples directory. This is a known SPM limitation when using executable targets that reference files in a shared directory. The warnings are harmless - all builds succeed and examples work correctly as separate executable targets.

### Debug Examples

Use the testing examples to debug specific functionality:

```bash
# Test provider fallback behavior
swift run QuickFallbackTest

# Test IP geolocation specifically  
swift run SimpleIPTest

# Comprehensive provider testing
swift run ProviderFallbackTest
```

## 📦 Release Process

### Preparation

```bash
# Full release preparation workflow
make release-prep

# This runs:
# - Clean build artifacts
# - Build project
# - Run all tests  
# - Generate documentation
# - Lint code (if available)
```

### Version Management

1. Update version numbers in relevant files
2. Update CHANGELOG.md
3. Create git tag: `git tag v1.2.0`
4. Push changes: `git push && git push --tags`

## 🤝 Contributing Guidelines

### Code Style

- Follow existing Swift conventions in the codebase
- Use meaningful variable and function names
- Document public APIs with proper Swift documentation comments
- Ensure thread safety for concurrent operations

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes with appropriate tests
4. Ensure all tests pass: `make test`
5. Generate documentation: `make docs`
6. Submit pull request with clear description

### Commit Messages

Use conventional commit format:
- `feat:` for new features
- `fix:` for bug fixes  
- `docs:` for documentation changes
- `test:` for test additions/changes
- `refactor:` for code refactoring

## 🔧 Advanced Development

### Adding New Providers

To add a new location provider:

1. Implement `LocationProviderContract`
2. Add provider to `CLLocationManagerService.init()`
3. Map to appropriate accuracy levels
4. Add tests for the new provider
5. Update documentation

### Extending Region Monitoring

Region monitoring can be extended by:

1. Implementing new region types (inherit from `CLRegion`)
2. Adding region-specific containment logic
3. Updating region monitoring service
4. Adding appropriate tests

### Cross-Platform Considerations

When making changes:
- Test on both macOS and Linux if possible
- Use conditional compilation when needed (`#if os(Linux)`)
- Ensure API compatibility with Apple's CoreLocation
- Document any platform-specific limitations

---

**For user documentation, see [README.md](README.md)**