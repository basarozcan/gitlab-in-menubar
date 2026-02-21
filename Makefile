VERSION ?= v1.0.2

SCHEME       = GitLabInMenubar
PROJECT      = GitLabInMenubar.xcodeproj
ARCHIVE_PATH = build/GitLabInMenubar.xcarchive
EXPORT_PATH  = build/export
APP_NAME     = GitLabInMenubar
EXPORT_PLIST = ExportOptions.plist

.PHONY: all run build export zip release clean

all: build export zip

run:
	@echo "🏃 Building and running $(SCHEME)..."
	@killall $(APP_NAME) 2>/dev/null || true
	@BUILT_DIR=$$(xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug -showBuildSettings 2>/dev/null | awk '/^ *BUILT_PRODUCTS_DIR/{print $$NF; exit}') && \
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug build && \
	open "$$BUILT_DIR/$(APP_NAME).app"

build:
	@echo "🔨 Building $(SCHEME)..."
	xcodebuild -project $(PROJECT) \
	  -scheme $(SCHEME) \
	  -configuration Release \
	  -archivePath $(ARCHIVE_PATH) \
	  archive

export: build
	@echo "📦 Exporting .app..."
	xcodebuild -exportArchive \
	  -archivePath $(ARCHIVE_PATH) \
	  -exportPath $(EXPORT_PATH) \
	  -exportOptionsPlist $(EXPORT_PLIST)

zip: export
	@echo "🗜️  Zipping..."
	cd $(EXPORT_PATH) && zip -r $(APP_NAME).zip $(APP_NAME).app

release: zip
	@echo "🚀 Releasing $(VERSION)..."
	git tag $(VERSION)
	git push origin $(VERSION)
	gh release create $(VERSION) $(EXPORT_PATH)/$(APP_NAME).zip \
	  --title "$(VERSION)" \
	  --notes-file CHANGELOG.md
	@echo "✅ $(VERSION) is live!"

clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf build/
