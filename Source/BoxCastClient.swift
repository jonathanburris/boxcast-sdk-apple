//
//  BoxCastClient.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation
import Alamofire

/// The client for the BoxCast API. Use the client to access resources of the BoxCast ecosystem.
public class BoxCastClient {
    
    let apiURL = "https://api.boxcast.com"
    let manager: SessionManager
    
    private enum Timeframe: String {
        case live = "current"
        case past = "past"
    }
    
    // MARK: - Shared Instance
    
    /// The shared singleton object to be used for accessing resources.
    public static let shared = BoxCastClient()
    
    internal init() {
        manager = SessionManager()
    }
    
    internal init(manager: SessionManager) {
        self.manager = manager
    }
    
    // MARK: - Accessing Resources
    
    /// Returns a list of live broadcasts for a specific channel.
    ///
    /// - Parameters:
    ///   - channelId: The channel id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getLiveBroadcasts(channelId: String, completionHandler: @escaping ((BroadcastList?, Error?) -> Void)) {
        findBroadcasts(channelId: channelId, timeframe: .live, completionHandler: completionHandler)
    }
    
    /// Returns a list of archived broadcasts for a specific channel.
    ///
    /// - Parameters:
    ///   - channelId: The channel id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getArchivedBroadcasts(channelId: String, completionHandler: @escaping ((BroadcastList?, Error?) -> Void)) {
        findBroadcasts(channelId: channelId, timeframe: .past, completionHandler: completionHandler)
    }
    
    /// Returns a detailed broadcast.
    ///
    /// - Parameters:
    ///   - broadcastId: The broadcast id.
    ///   - channelId: The channel id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getBroadcast(broadcastId: String, channelId: String, completionHandler: @escaping ((Broadcast?, Error?) -> Void)) {
        let request = manager.request("\(apiURL)/broadcasts/\(broadcastId)")
        request
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = response.flatMap { json in
                    return try Broadcast(channelId: channelId, json: json)
                }
                completionHandler(result.value, result.error)
        }
    }
    
    /// Returns a view for a specific broadcast.
    ///
    /// - Parameters:
    ///   - broadcastId: The broadcast id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getBroadcastView(broadcastId: String, completionHandler: @escaping ((BroadcastView?, Error?) -> Void)) {
        let request = manager.request("\(apiURL)/broadcasts/\(broadcastId)/view")
        request
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = response.flatMap { json in
                    return try BroadcastView(json: json)
                }
                completionHandler(result.value, result.error)
        }
    }
    
    // MARK: - Private
    
    private func findBroadcasts(channelId: String, timeframe: Timeframe,
                                completionHandler: @escaping (([Broadcast]?, Error?) -> Void)) {
        // Build the query.
        let query = QueryBuilder()
        query.appendWithLogic(.or, key: "timeframe", value: timeframe.rawValue)
        let params = [
            "q" : query.build()
        ]
        let request = manager.request("\(apiURL)/channels/\(channelId)/broadcasts",
                                      parameters: params)
        request
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = response.flatMap { json in
                    return try BroadcastList(channelId: channelId, json: json)
                }
                completionHandler(result.value, result.error)
        }
        
    }
}
