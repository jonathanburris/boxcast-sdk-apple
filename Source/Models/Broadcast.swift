//
//  Broadcast.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation
import Alamofire

public typealias BroadcastList = [Broadcast]

public struct Broadcast {
    
    public let id: String
    public let name: String
    public let description: String
    public let thumbnailURL: URL
    public let channelId: String
    let accountId: String?
    
    init(id: String, name: String, description: String, thumbnailURL: URL, channelId: String,
         accountId: String?=nil) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.channelId = channelId
        self.accountId = accountId
    }
    
    init(channelId: String, json: Any) throws {
        guard let dict = json as? Dictionary<String, Any> else {
            throw BoxCastError.serializationError
        }
        guard
            let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let description = dict["description"] as? String,
            let thumbnailURLString = dict["preview"] as? String else {
                throw BoxCastError.serializationError
        }
        guard let thumbnailURL = URL(string: thumbnailURLString) else {
            throw BoxCastError.serializationError
        }
        self.id = id
        self.accountId = dict["account_id"] as? String
        self.channelId = channelId
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
    }
    
}

extension Array where Element == Broadcast {
    init(channelId: String, json: Any) throws {
        guard let array = json as? Array<Any> else {
            throw BoxCastError.serializationError
        }
        let broadcasts = try array.flatMap { json in
            return try Broadcast(channelId: channelId, json: json)
        }
        self.init(broadcasts)
    }
}
