SCHEME = XCTestTemp

.PHONY: build test lint

ci: lint test

lint:
	swiftlint

build:
	xcodebuild build

test:
	xcodebuild test \
		-alltargets \
		-configuration Debug \
		-scheme $(SCHEME)
