# `XCTestTemp` [![Build Status](https://travis-ci.org/robenkleene/XCTestTemp.svg?branch=master)](https://travis-ci.org/robenkleene/XCTestTemp)

A simple `XCTestCase` subclass that creates a temporary directory that the tests can use. If the temporary directory is not completely empty after the test 

* It's macOS only.
* Install with [Carthage](https://github.com/Carthage/Carthage).

Usage:

	class MyTest: TemporaryDirectoryTestCase {
		override func setUp() {
			super.setUp()
			// Use `temporaryDirectoryURL`, etc... here
		}

		override func tearDown() {
			// Make sure the temporary directory is empty before calling the
			// teardown otherwise, the test will fail an assertion!
			super.tearDown()
		}
	}
 
Access the temporary directory:

    var temporaryDirectoryPath: String!
    var temporaryDirectoryURL: URL! {

Normalizing a path by following symlinks:

	class func resolve(temporaryDirectoryPath path: String) -> String {

Remove temporary items:

	func removeTemporaryItem(atPathComponent pathComponent: String) throws {
	func removeTemporaryItem(at URL: URL) throws {
	func removeTemporaryItem(atPath path: String) throws {
