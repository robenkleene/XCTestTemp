SCHEME = XCTestTemp

.PHONY: build test lint autocorrect swiftformat swiftlint_autocorrect bootstrap

ci: test
ac: autocorrect
autocorrect: swiftformat swiftlint_autocorrect

lint:
	swiftlint --strict

swiftformat:
	git ls-files '*.swift' -z | xargs -0 swiftformat --commas inline

swiftlint_autocorrect:
	swiftlint autocorrect

build:
	xcodebuild build \
		-alltargets \
		-configuration Debug

bootstrap:
	carthage bootstrap

test:
	xcodebuild test \
		-alltargets \
		-configuration Debug \
		-scheme $(SCHEME)

