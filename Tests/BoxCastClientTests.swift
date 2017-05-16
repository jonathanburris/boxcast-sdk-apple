//
//  BoxCastClientTests.swift
//  BoxCastTests
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import XCTest
import Alamofire
@testable import BoxCast

class BoxCastClientTests: XCTestCase {
    
    var client: BoxCastClient?
    var manager: SessionManager?
    
    override func setUp() {
        super.setUp()
        
        // Set up mocking of the responses.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses?.insert(MockedURLProtocol.self, at: 0)
        manager = SessionManager(configuration: configuration)
        client = BoxCastClient(manager: manager!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApiEndpoint() {
        XCTAssertEqual(client?.apiURL, "https://api.boxcast.com")
    }
    
    func testGetLiveBroadcasts() {
        let data = (
            "[{" +
                "\"id\":\"1\"," +
                "\"name\": \"Test\"," +
                "\"description\":\"A test broadcast.\"," +
                "\"channel_id\":\"1\"," +
                "\"preview\": \"https://api.boxcast.com/thumbnail.jpg\"" +
            "}]"
            ).data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetLiveBroadcasts")
        var liveBroadcasts: BroadcastList?
        client?.getLiveBroadcasts(channelId: "1") { broadcasts, error in
            liveBroadcasts = broadcasts
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNotNil(liveBroadcasts)
            XCTAssertEqual(liveBroadcasts?.count, 1)
        }
    }
    
    func testGetArchivedBroadcasts() {
        let data = (
            "[{" +
                "\"id\":\"1\"," +
                "\"name\": \"Test\"," +
                "\"description\":\"A test broadcast.\"," +
                "\"channel_id\":\"1\"," +
                "\"preview\": \"https://api.boxcast.com/thumbnail.jpg\"" +
            "}]"
            ).data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetArchivedBroadcasts")
        var archivedBroadcasts: BroadcastList?
        client?.getArchivedBroadcasts(channelId: "1") { broadcasts, error in
            archivedBroadcasts = broadcasts
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNotNil(archivedBroadcasts)
            XCTAssertEqual(archivedBroadcasts?.count, 1)
        }
    }
    
    func testGetBroadcast() {
        let data = (
            "{" +
                "\"id\":\"1\"," +
                "\"name\": \"Test\"," +
                "\"description\":\"A test broadcast.\"," +
                "\"account_id\":\"1\"," +
                "\"channel_id\":\"1\"," +
                "\"preview\": \"https://api.boxcast.com/thumbnail.jpg\"" +
            "}"
            ).data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetLiveBroadcasts")
        var broadcast: Broadcast?
        client?.getBroadcast(broadcastId: "1", channelId: "2") { b, error in
            broadcast = b
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNotNil(broadcast)
            XCTAssertEqual(broadcast?.id, "1")
            XCTAssertEqual(broadcast?.accountId, "1")
            XCTAssertEqual(broadcast?.channelId, "2")
            XCTAssertEqual(broadcast?.name, "Test")
            XCTAssertEqual(broadcast?.description, "A test broadcast.")
            XCTAssertEqual(broadcast?.thumbnailURL, URL(string: "https://api.boxcast.com/thumbnail.jpg")!)
        }
    }
    
    func testGetBroadcastView() {
        let data = "{\"playlist\": \"https://api.boxcast.com/playlist\", \"status\": \"live\"}".data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetLiveBroadcasts")
        var broadcastView: BroadcastView?
        client?.getBroadcastView(broadcastId: "1") { view, error in
            broadcastView = view
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertEqual(broadcastView?.playlistURL, URL(string: "https://api.boxcast.com/playlist")!)
            XCTAssertEqual(broadcastView?.status, .live)
        }
    }
    
}
