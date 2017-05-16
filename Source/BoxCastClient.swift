//
//  BoxCastClient.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation
import Alamofire

public class BoxCastClient {
    
    let apiURL = "https://api.boxcast.com"
    let manager: SessionManager
    
    private enum Timeframe: String {
        case live = "current"
        case past = "past"
    }
    
    // MARK: - Lifecycle
    
    public static let shared = BoxCastClient()
    
    internal init() {
        manager = SessionManager()
    }
    
    internal init(manager: SessionManager) {
        self.manager = manager
    }
    
    // MARK: - Public
    
    public func getLiveBroadcasts(channelId: String,
                                  completion: @escaping ((BroadcastList?, Error?) -> Void)) {
        findBroadcasts(channelId: channelId, timeframe: .live, completion: completion)
    }
    
    public func getArchivedBroadcasts(channelId: String,
                                      completion: @escaping ((BroadcastList?, Error?) -> Void)) {
        findBroadcasts(channelId: channelId, timeframe: .past, completion: completion)
    }
    
    public func getBroadcast(broadcastId: String, channelId: String,
                             completion: @escaping ((Broadcast?, Error?) -> Void)) {
        let request = manager.request("\(apiURL)/broadcasts/\(broadcastId)")
        request
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = response.flatMap { json in
                    return try Broadcast(channelId: channelId, json: json)
                }
                completion(result.value, result.error)
        }
    }
    
    public func getBroadcastView(broadcastId: String,
                                 completion: @escaping ((BroadcastView?, Error?) -> Void)) {
        let request = manager.request("\(apiURL)/broadcasts/\(broadcastId)/view")
        request
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                let result = response.flatMap { json in
                    return try BroadcastView(json: json)
                }
                completion(result.value, result.error)
        }
    }
    
    // MARK: - Private
    
    private func findBroadcasts(channelId: String, timeframe: Timeframe,
                                completion: @escaping (([Broadcast]?, Error?) -> Void)) {
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
                completion(result.value, result.error)
        }
        
    }
}
