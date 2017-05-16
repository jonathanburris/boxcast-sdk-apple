//
//  BoxCastPlayer.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/14/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import AVFoundation

public class BoxCastPlayer : AVPlayer {
    
    let metricsConsumer: MetricsConsumer
    var totalTime: CMTime
    var lastSentTime: CMTime
    var lastPlayTime: CMTime?
    var intervalTimer: RepeatingTimer?
    
    // MARK: - Lifecycle
    
    public init?(broadcast: Broadcast, broadcastView: BroadcastView) {
        if let url = broadcastView.playlistURL {
            let item = AVPlayerItem(url: url)
            totalTime = CMTime(seconds: 0, preferredTimescale: 1)
            lastSentTime = CMTime(seconds: 0, preferredTimescale: 1)
            metricsConsumer = MetricsConsumer(broadcast: broadcast, broadcastView: broadcastView)
            super.init()
            replaceCurrentItem(with: item)
            addObservers()
            sendSetupMetric()
        } else {
            return nil
        }
    }
    
    deinit {
        removeObservers()
        stopIntervalTimer()
    }
    
    // MARK: - Key Value Observing
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                      change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let player = object as? BoxCastPlayer else {
            return
        }
        
        if keyPath == "rate" {
            let currentTime = player.currentTime()
            let rate = player.rate
            var action: Metric.Action
            var metric: Metric
            
            // TODO: Handle rates other than just 0 and 1?
            if rate == 0 {
                if let lastPlayTime = lastPlayTime {
                    totalTime = totalTime + (currentTime - lastPlayTime)
                    self.lastPlayTime = nil
                }
                if player.currentItem!.isPlaybackBufferEmpty {
                    action = .buffer
                } else {
                    action = .pause
                }
            } else {
                lastPlayTime = currentTime
                if intervalTimer == nil {
                    createIntervalTimer()
                }
                action = .play
            }
            metric = Metric(action: action, time: currentTime, totalTime: totalTime)
            send(metric: metric)
        }
    }
    
    // MARK: - Notifications
    
    func playerItemDidPlayToEndTime(_ sender: AnyObject?) {
        sendCompleteMetric()
    }
    
    func playerItemTimeJumped(_ sender: AnyObject?) {
        sendSeekMetric()
    }
    
    // MARK: - Timers
    
    func intervalTimerFired() {
        sendTimeMetric()
    }
    
    // MARK: - Private
    
    private func addObservers() {
        addObserver(self, forKeyPath: "rate", options: [.new], context: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)),
                           name: .AVPlayerItemDidPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(playerItemTimeJumped(_:)),
                           name: .AVPlayerItemTimeJumped, object: nil)
    }
    
    private func removeObservers() {
        removeObserver(self, forKeyPath: "rate")

        let center = NotificationCenter.default
        center.removeObserver(self)
    }
    
    private func createIntervalTimer() {
        guard intervalTimer == nil else {
            return
        }
        
        let action = TimerAction {
            [weak self] in // Careful of a retain cycle.
            self?.sendTimeMetric()
        }
        intervalTimer = RepeatingTimer(interval: 60, action: action)
    }
    
    private func stopIntervalTimer() {
        intervalTimer?.invalidate()
    }
    
    private func sendSetupMetric() {
        let metric = Metric(action: .setup, time: currentTime(), totalTime: totalTime)
        send(metric: metric)
    }
    
    private func sendCompleteMetric() {
        let currentTime = self.currentTime()
        if let lastPlayTime = lastPlayTime {
            totalTime = totalTime + (currentTime - lastPlayTime)
        }
        
        let metric = Metric(action: .setup, time: currentTime, totalTime: totalTime)
        send(metric: metric)
    }
    
    private func sendTimeMetric() {
        let currentTime = self.currentTime()
        // Don't modify totalTime since we aren't resetting lastPlayTime.
        var totalTime = self.totalTime
        if let lastPlayTime = lastPlayTime {
            totalTime = totalTime + (currentTime - lastPlayTime)
        }
        
        let metric = Metric(action: .time, time: currentTime, totalTime: totalTime)
        send(metric: metric)
    }
    
    private func sendSeekMetric() {
        let currentTime = self.currentTime()
        if let lastPlayTime = lastPlayTime {
            totalTime = totalTime + (currentTime - lastPlayTime)
        }
        
        // The seek metric wants the time to be the time before seeking occured. Unfortunately,
        // we only get the time after the seek has happened so we store the last sent time for all
        // sent metrics to handle this.
        let metric = Metric(action: .seek(toTime: currentTime), time: lastSentTime,
                            totalTime: totalTime)
        send(metric: metric)
    }
    
    private func send(metric: Metric) {
        metricsConsumer.consume(metric: metric)
        switch metric.action{
        case .seek(let toTime): lastSentTime = toTime
        default: lastSentTime = metric.time
        }
    }
}

class RepeatingTimer {
    var timer: Timer?
    var actions: [TimerAction]
    
    init(interval: TimeInterval, action: TimerAction) {
        actions = [action]
        timer = Timer.scheduledTimer(timeInterval: interval, target: self,
                                     selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    func invalidate() {
        actions.removeAll()
        timer?.invalidate()
        timer = nil
    }
    @objc func timerFired() {
        for action in actions {
            action.block()
        }
    }
}

class TimerAction {
    let block: (Void) -> Void
    init(block: @escaping (Void) -> Void) {
        self.block = block
    }
}
