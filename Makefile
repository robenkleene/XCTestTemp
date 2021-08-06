SCHEME = XCTestTemp

.PHONY: build test lint autocorrect swiftformat swiftlint_autocorrect loc archive

ci: build
ac: autocorrect
autocorrect: swiftformat swiftlint_autocorrect

lint:
	swiftlint --strict

swiftformat:
	git ls-files '*.swift' -z | xargs -0 swiftformat --commas inline

swiftlint_autocorrect:
	swiftlint autocorrect

archive:
	carthage build --no-skip-current
	carthage archive XCTestTemp

build:
	xcodebuild build \
		-alltargets \
		-configuration Debug

test:
	xcodebuild test \
		-alltargets \
		-configuration Debug \
		-scheme $(SCHEME)

loc:
	cloc --vcs=git
