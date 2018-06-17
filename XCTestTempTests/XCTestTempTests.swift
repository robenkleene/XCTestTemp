//
//  XCTestTempTests.swift
//  XCTestTempTests
//
//  Created by Roben Kleene on 5/2/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import XCTest
import XCTestTemp

class XCTestTempTests: TemporaryDirectoryTestCase {
    let testFilename = "test.txt"
    let testFileContents = "test"

    func testTemp() {
        let fileURL = urlForTemporaryItem(withPathComponent: testFilename)
        do {
            try testFileContents.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            XCTFail()
        }

        XCTAssertTrue(isTemporaryItem(at: fileURL))
        XCTAssertTrue(isTemporaryItem(atPath: fileURL.path))

        do {
            let result = try String(contentsOf: fileURL, encoding: String.Encoding.utf8)
            XCTAssertEqual(result, testFileContents)
            try removeTemporaryItem(withPathComponent: testFilename)
        } catch {
            XCTFail()
        }
    }
}
