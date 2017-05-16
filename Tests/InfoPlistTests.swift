//
//  InfoPlistTests.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/16/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import XCTest
@testable import BoxCast

class InfoPlistTests: XCTestCase {
    
    func testAppName() {
        XCTAssertEqual(InfoPlist.appName, "Unknown")
    }
    
    func testAppVersion() {
        XCTAssertEqual(InfoPlist.appVersion, "Unknown")
    }
    
    func testAppBuild() {
        XCTAssertEqual(InfoPlist.appBuild, "Unknown")
    }
    
    func testAppBundleIdentifier() {
        XCTAssertEqual(InfoPlist.appBundleIndentifier, "Unknown")
    }
    
    func testBoxCastSDKVersion() {
        XCTAssertEqual(InfoPlist.boxCastSDKVersion, "1.0.0")
    }
    
}
