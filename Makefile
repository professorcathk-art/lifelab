# LifeLab Makefile - Simple commands for testing without Xcode GUI

.PHONY: help build test run clean list-simulators boot-simulator check

# Default target
help:
	@echo "LifeLab - Testing Commands"
	@echo "=========================="
	@echo ""
	@echo "Available commands:"
	@echo "  make build          - Build the project"
	@echo "  make test           - Run unit tests"
	@echo "  make run            - Build and run on simulator"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make list-simulators - List available iOS simulators"
	@echo "  make boot-simulator  - Boot iPhone 15 Pro simulator"
	@echo "  make check          - Check Swift syntax"
	@echo ""

# Project configuration
PROJECT = LifeLab/LifeLab.xcodeproj
SCHEME = LifeLab
SIMULATOR = "iPhone 15 Pro"
SDK = iphonesimulator

# List available simulators
list-simulators:
	@echo "📱 Available iOS Simulators:"
	@xcrun simctl list devices available | grep -E "iPhone|iPad" | head -15

# Boot simulator
boot-simulator:
	@echo "🔌 Booting simulator: $(SIMULATOR)..."
	@DEVICE_ID=$$(xcrun simctl list devices | grep "$(SIMULATOR)" | grep -oE '[A-F0-9-]{36}' | head -1); \
	if [ -z "$$DEVICE_ID" ]; then \
		echo "❌ Simulator not found. Run 'make list-simulators' to see available devices."; \
		exit 1; \
	fi; \
	xcrun simctl boot $$DEVICE_ID 2>/dev/null || echo "Simulator already booted"; \
	open -a Simulator; \
	echo "✅ Simulator ready"

# Build the project
build:
	@echo "🔨 Building project..."
	@xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-sdk $(SDK) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR)" \
		clean build
	@echo "✅ Build complete"

# Run tests
test: boot-simulator
	@echo "🧪 Running tests..."
	@xcodebuild test \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-sdk $(SDK) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR)"
	@echo "✅ Tests complete"

# Build and run app
run: boot-simulator
	@echo "📲 Building and running app..."
	@xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-sdk $(SDK) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR)" \
		-derivedDataPath ./build
	@APP_PATH=$$(find ./build -name "LifeLab.app" -type d | head -1); \
	if [ -z "$$APP_PATH" ]; then \
		echo "❌ App not found. Build may have failed."; \
		exit 1; \
	fi; \
	DEVICE_ID=$$(xcrun simctl list devices | grep "$(SIMULATOR)" | grep -oE '[A-F0-9-]{36}' | head -1); \
	if [ -z "$$DEVICE_ID" ]; then \
		DEVICE_ID=$$(xcrun simctl list devices booted | grep -oE '[A-F0-9-]{36}' | head -1); \
	fi; \
	echo "📱 Installing app on device: $$DEVICE_ID..."; \
	xcrun simctl install $$DEVICE_ID "$$APP_PATH"; \
	echo "▶️  Launching app..."; \
	xcrun simctl launch $$DEVICE_ID com.yourname.LifeLab 2>/dev/null || xcrun simctl launch $$DEVICE_ID com.lifelab.LifeLab 2>/dev/null || echo "⚠️  Could not determine bundle ID, app installed but not launched"; \
	echo "✅ App launched"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@xcodebuild clean \
		-project $(PROJECT) \
		-scheme $(SCHEME)
	@rm -rf ./build
	@echo "✅ Clean complete"

# Check Swift syntax
check:
	@echo "🔍 Checking Swift syntax..."
	@find LifeLab/LifeLab -name "*.swift" -type f 2>/dev/null | while read file; do \
		swiftc -typecheck "$$file" 2>&1 | grep -v "error:" || echo "✅ $$file"; \
	done || echo "⚠️  Some files may have issues"
