//
//  TemporaryDirectoryTestCase.swift
//  XCTestTemp
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

enum TemporaryDirectoryError: Error {
    case notInTemporaryDirectoryError(path: String)
    case invalidURLError(URL: URL)
}

open class TemporaryDirectoryTestCase: XCTestCase {

    // MARK: Public

    public var temporaryDirectoryPath: String!
    public var temporaryDirectoryURL: URL! {
        return URL(fileURLWithPath: temporaryDirectoryPath)
    }

    public var identifier: String {
        let removeCharacterSet = NSCharacterSet.alphanumerics.inverted
        // The `"\(className)"` might also be useful for the identifier.
        return String(describing: self)
            .trimmingCharacters(in: removeCharacterSet)
            .replacingOccurrences(of: " ", with: ".")
    }

    struct ClassConstants {
        static let temporaryDirectoryPathPrefix = "/var/folders"
    }

    // MARK: Public

    public class func resolve(temporaryDirectoryPath path: String) -> String {
        // Remove the `/private` path component that `FSEvents` returns paths
        // with this prefix.
        let testPathPrefix = ("/private" as NSString)
            .appendingPathComponent(ClassConstants.temporaryDirectoryPathPrefix)
        let pathPrefixRange = (path as NSString).range(of: testPathPrefix)
        if pathPrefixRange.location == 0 {
            return (path as NSString).replacingCharacters(in: pathPrefixRange,
                                                          with: ClassConstants.temporaryDirectoryPathPrefix)
        }

        return path
    }

    private class func isValidTemporaryDirectory(atPath path: String) -> Bool {
        var isDir: ObjCBool = false

        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }

    public func urlForTemporaryItem(withPathComponent pathComponent: String) -> URL {
        let path = pathForTemporaryItem(withPathComponent: pathComponent)
        return URL(fileURLWithPath: path)
    }

    public func pathForTemporaryItem(withPathComponent pathComponent: String) -> String {
        return (temporaryDirectoryPath as NSString).appendingPathComponent(pathComponent)
    }

    public func removeTemporaryItem(withPathComponent pathComponent: String) throws {
        let path = (temporaryDirectoryPath as NSString).appendingPathComponent(pathComponent)
        do {
            try type(of: self).safelyRemoveTemporaryItem(atPath: path)
        } catch let error as NSError {
            throw error
        }
    }

    public func removeTemporaryItem(at URL: URL) throws {
        do {
            try removeTemporaryItem(atPath: URL.path)
        } catch let error as NSError {
            throw error
        }
    }

    public func removeTemporaryItem(atPath path: String) throws {
        if !path.hasPrefix(temporaryDirectoryPath) {
            throw TemporaryDirectoryError.notInTemporaryDirectoryError(path: path)
        }
        do {
            try type(of: self).safelyRemoveTemporaryItem(atPath: path)
        } catch let error as NSError {
            throw error
        }
    }

    public func isTemporaryItem(atPath path: String) -> Bool {
        return path.hasPrefix(ClassConstants.temporaryDirectoryPathPrefix)
    }

    public func isTemporaryItem(at url: URL) -> Bool {
        return url.path.hasPrefix(ClassConstants.temporaryDirectoryPathPrefix)
    }

    // MARK: Private

    private class func safelyRemoveTemporaryItem(atPath path: String) throws {
        if !path.hasPrefix(ClassConstants.temporaryDirectoryPathPrefix) {
            throw TemporaryDirectoryError.notInTemporaryDirectoryError(path: path)
        }

        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            throw error
        }
    }

    // MARK: Override

    open override func setUp() {
        super.setUp()

        if let temporaryDirectory = NSTemporaryDirectory() as String? {
            let path = (temporaryDirectory as NSString).appendingPathComponent(identifier)

            if FileManager.default.fileExists(atPath: path) {
                do {
                    try type(of: self).safelyRemoveTemporaryItem(atPath: path)
                } catch let error as NSError {
                    XCTAssertTrue(false, "Removing the temporary directory should have succeeded \(error)")
                }
                // This is not an assert in order to make it easier to fix tests
                // that aren't cleaning up after themselves.
                print("Warning: A temporary directory had to be cleaned up at path \(path)")
            }
            XCTAssertFalse(FileManager.default.fileExists(atPath: path), "A file should not exist at the path")
            do {
                try FileManager.default
                    .createDirectory(atPath: path,
                                     withIntermediateDirectories: true,
                                     attributes: nil)
            } catch let error as NSError {
                XCTAssertNil(false, "Creating the directory should succeed \(error)")
            }

            temporaryDirectoryPath = path
        }

        XCTAssertTrue(type(of: self).isValidTemporaryDirectory(atPath: temporaryDirectoryPath))
    }

    open override func tearDown() {
        super.tearDown()

        XCTAssertTrue(type(of: self).isValidTemporaryDirectory(atPath: temporaryDirectoryPath))

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectoryPath)
            if !contents.isEmpty {
                print("""
                Warning: A temporary directory was not empty during tear down at
                path \(String(describing: temporaryDirectoryPath))
                """)
            }
            XCTAssert(contents.isEmpty, "The contents should be empty")

            // Remove the temporary directory
            try type(of: self).safelyRemoveTemporaryItem(atPath: temporaryDirectoryPath)
        } catch let error as NSError {
            XCTAssertTrue(false, "Failed to clean up a temporary directory \(error)")
        }

        // Confirm the temporary directory is removed
        XCTAssertFalse(type(of: self).isValidTemporaryDirectory(atPath: temporaryDirectoryPath))
        XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryDirectoryPath))
        temporaryDirectoryPath = nil
    }
}
