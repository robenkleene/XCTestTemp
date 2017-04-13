//
//  TemporaryDirectoryTestCase.swift
//  XCTestTemp
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

// TODO: Put this in the appropriate spot
// XCTAssert(false, "Attempted to delete a temporary item that is not in the temporary directory.")
// XCTAssert(false, "Attempted to delete a temporary item at a path that does not have the temporary directory path prefix.")

enum TemporaryDirectoryError: Error {
    case notInTemporaryDirectoryError(path: String)
    case invalidURLError(URL: URL)
}

class TemporaryDirectoryTestCase: XCTestCase {
    var temporaryDirectoryPath: String!
    var temporaryDirectoryURL: URL! {
        get {
            return URL(fileURLWithPath:temporaryDirectoryPath)
        }
    }

    struct ClassConstants {
        static let bundleIdentifier = Bundle.main.bundleIdentifier!
        static let temporaryDirectoryPathPrefix = "/var/folders"
    }
    
    class func resolve(temporaryDirectoryPath path: String) -> String {
        // Remove the `/private` path component that `FSEvents` returns paths
        // with this prefix.
        let testPathPrefix = ("/private" as NSString).appendingPathComponent(ClassConstants.temporaryDirectoryPathPrefix)
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
    
    func removeTemporaryItem(atPathComponent pathComponent: String) throws {
        let path = (temporaryDirectoryPath as NSString).appendingPathComponent(pathComponent)
        do {
            try type(of: self).safelyRemoveTemporaryItem(atPath: path)
        } catch let error as NSError {
            throw error
        }
    }

    func removeTemporaryItem(at URL: URL) throws {
        do {
            try removeTemporaryItem(atPath: URL.path)
        } catch let error as NSError {
            throw error
        }
    }
    
    func removeTemporaryItem(atPath path: String) throws {
        if !path.hasPrefix(temporaryDirectoryPath) {
            throw TemporaryDirectoryError.notInTemporaryDirectoryError(path: path)
        }
        do {
            try type(of: self).safelyRemoveTemporaryItem(atPath: path)
        } catch let error as NSError {
            throw error
        }
    }
    
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
    
    override func setUp() {
        super.setUp()

        if let temporaryDirectory = NSTemporaryDirectory() as String? {
            let identifierDirectoryPath = (temporaryDirectory as NSString).appendingPathComponent(ClassConstants.bundleIdentifier)
            let path = (identifierDirectoryPath as NSString).appendingPathComponent(className)
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try type(of: self).safelyRemoveTemporaryItem(atPath: path)
                } catch let error as NSError {
                    XCTAssertTrue(false, "Removing the temporary directory should have succeeded \(error)")
                }
                // This is not an assert in order to make it easier to fix tests that aren't cleaning up after themselves.
                print("Warning: A temporary directory had to be cleaned up at path \(path)")
            }
            XCTAssertFalse(FileManager.default.fileExists(atPath: path), "A file should not exist at the path")
            do {
                try FileManager.default
                    .createDirectory(atPath: path,
                        withIntermediateDirectories: true,
                        attributes: nil)
            } catch let error as NSError {
                XCTAssertNil(false ,"Creating the directory should succeed \(error)")
            }
            
            temporaryDirectoryPath = path
        }

        XCTAssertTrue(type(of: self).isValidTemporaryDirectory(atPath: temporaryDirectoryPath), "The temporary directory path should be valid")
    }
    
    override func tearDown() {
        super.tearDown()
        
        XCTAssertTrue(type(of: self).isValidTemporaryDirectory(atPath: temporaryDirectoryPath), "The temporary directory path should be valid")

        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectoryPath)
            if !contents.isEmpty {
                print("Warning: A temporary directory was not empty during tear down at path \(temporaryDirectoryPath)")
            }
            // This is an assert because it is evidence that a plugin isn't cleaning up after itself.
            // On next run the setup will clean it up, so the assert helps identify when a test isn't
            // cleaning up without hindering future runs.
            XCTAssert(contents.isEmpty, "The contents should be empty")

            // Remove the temporary directory
            try type(of: self).safelyRemoveTemporaryItem(atPath: temporaryDirectoryPath)
        } catch let error as NSError {
            XCTAssertTrue(false, "Failed to clean up a temporary directory \(error)")
        }

        // Confirm the temporary directory is removed
        XCTAssertFalse(type(of: self).isValidTemporaryDirectory(atPath: temporaryDirectoryPath), "The temporary directory path should be invalid")
        XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryDirectoryPath), "A file should not exist at the path")
        temporaryDirectoryPath = nil
    }
}
