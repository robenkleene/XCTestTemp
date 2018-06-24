SCHEME = XCTestTemp

.PHONY: build test lint autocorrect swiftformat swiftlint_autocorrect

ci: lint test
ac: autocorrect
autocorrect: swiftformat swiftlint_autocorrect

lint:
	swiftlint --strict

swiftformat:
	swiftformat --commas inline .

swiftlint_autocorrect:
	swiftlint autocorrect

build:
	xcodebuild build

test:
	xcodebuild test \
		-alltargets \
		-configuration Debug \
		-scheme $(SCHEME)
