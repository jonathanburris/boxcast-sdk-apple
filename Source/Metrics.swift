//
//  Metrics.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/14/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation
import Alamofire
import CoreMedia

struct Metric {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    enum Action {
        case setup
        case play
        case pause
        case buffer
        case seek(toTime: CMTime)
        case time
        case complete
    }
    
    let action: Action
    let time: CMTime
    let totalTime: CMTime
    let timestamp: Date
    
    init(action: Action, time: CMTime, totalTime: CMTime) {
        self.action = action
        self.time = time
        self.totalTime = totalTime
        self.timestamp = Date()
    }
    
}

protocol JSONDeserializable {
    func deserialized() -> Parameters
}

extension Metric.Action: JSONDeserializable {
    func deserialized() -> Parameters {
        var params: Parameters = [:]
        switch self {
        case .setup:
            params["action"] = "setup"
            params["user_agent"] = "\(InfoPlist.appName)/\(InfoPlist.appVersion) (\(InfoPlist.appBundleIndentifier); build:\(InfoPlist.appBuild); \(System.osName) \(System.osVersion)) BoxCast SDK/\(InfoPlist.boxCastSDKVersion)"
            params["platform"] = System.osName
            params["browser_name"] = System.osName
            params["os"] = System.osName
            params["browser_version"] = System.osVersion
            params["model"] = Device.modelIdentifierString
            params["product_type"] = ""
            params["system_version"] = System.osVersion
            params["vendor_identifier"] = ""
            params["player_version"] = InfoPlist.boxCastSDKVersion
            params["host"] = "\(InfoPlist.appName) for \(System.osName)"
            params["language"] = ""
            params["remote_ip"] = ""
        case .play: params["action"] = "play"
        case .pause: params["action"] = "pause"
        case .buffer: params["action"] = "buffer"
        case .seek(let toTime):
            params["action"] = "seek"
            params["offset"] = toTime.seconds
        case .time: params["action"] = "time"
        case .complete: params["action"] = "complete"
        }
        return params
    }
}

extension Metric: JSONDeserializable {
    func deserialized() -> Parameters {
        var params: Parameters = [
            "position": time.seconds,
            "duration": totalTime.seconds,
            "timestamp": Metric.dateFormatter.string(from: timestamp),
            ]
        action.deserialized().forEach { params[$0] = $1 }
        return params
    }
}

extension Metric: CustomStringConvertible {
    var description: String {
        return "action: \(action.description), time: \(time.seconds), totalTime: \(totalTime.seconds)"
    }
}

extension Metric.Action: CustomStringConvertible {
    var description: String {
        switch self {
        case .setup: return "setup"
        case .play: return "play"
        case .pause: return "pause"
        case .buffer: return "buffer"
        case .seek(let toTime): return "seek (to \(toTime.seconds))"
        case .time: return "time"
        case .complete: return "complete"
        }
    }
}

class MetricsConsumer {

    let metricsURL = "https://metrics.boxcast.com"
    let headers = [
        "Accept" : "application/json"
    ]
    let appName: String
    let manager: SessionManager
    let broadcast: Broadcast
    let broadcastView: BroadcastView
    let viewId: String
    
    // MARK: - Lifecycle
    
    convenience init(broadcast: Broadcast, broadcastView: BroadcastView) {
        let manager = SessionManager()
        self.init(broadcast: broadcast, broadcastView: broadcastView, manager: manager)
    }
    
    init(broadcast: Broadcast, broadcastView: BroadcastView, manager: SessionManager) {
        self.broadcast = broadcast
        self.broadcastView = broadcastView
        self.manager = manager
        appName = InfoPlist.appName
        viewId = UUID().uuidString
    }
    
    // MARK: - Internal
    
    func consume(metric: Metric) {
        guard let accountId = broadcast.accountId else {
            print("there is no account id, broadcast was not detailed")
            return
        }
        
        print("consuming: \(metric)")
        
        var params: Parameters = [
            // ???: If the status was "stalled" wouldn't this incorrectly report is_live = false
            "is_live" : broadcastView.status == .live,
            "account_id" : accountId,
            "broadcast_id" : broadcast.id,
            "channel_id" : broadcast.channelId,
            "view_id" : viewId,
            "viewer_id" : viewerId,
        ]
        metric.deserialized().forEach { params[$0] = $1 }
        
        let request = manager.request("\(metricsURL)/player/interaction", method: .post,
                                      parameters: params, encoding: JSONEncoding.default,
                                      headers: headers)
        request
            .validate(statusCode: 200..<300)
            .response { response in
                if let error = response.error {
                    print("error posting metric: \(error.localizedDescription)")
                }
            }
    }
    
    // MARK: - Internal
    
    var viewerId: String {
        guard let defaults = UserDefaults.boxCastDefaults else {
            return UUID().uuidString
        }
        if let id = defaults.string(forKey: "viewerId") {
            return id
        } else {
            let id = UUID().uuidString
            defaults.set(id, forKey: "viewerId")
            return id
        }
    }
}

