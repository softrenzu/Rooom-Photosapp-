.PHONY: project test screenshots validate

project:
	xcodegen generate

test: project
	xcodebuild test -project RooomShot.xcodeproj -scheme RooomShot -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=latest' CODE_SIGNING_ALLOWED=NO

screenshots: project
	bash scripts/generate_screenshots.sh

validate:
	bash scripts/validate_repository.sh

