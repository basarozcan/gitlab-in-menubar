VERSION ?= v1.0.1

SCHEME       = GitLabMRStatus
PROJECT      = GitLabMRStatus.xcodeproj
ARCHIVE_PATH = build/GitLabMRStatus.xcarchive
EXPORT_PATH  = build/export
APP_NAME     = GitLabMRStatus
EXPORT_PLIST = ExportOptions.plist

.PHONY: all build export zip release clean

all: build export zip

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
