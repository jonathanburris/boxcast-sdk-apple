//
//  ViewController.swift
//  Demo
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import UIKit
import BoxCast

class ViewController: UITableViewController {
    
    let channelId = "YOUR_CHANNEL_ID"
    var liveBroadcasts: BroadcastList = []
    var archivedBroadcasts: BroadcastList = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadBroadcasts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "BroadcastSegue",
            let indexPath = sender as? IndexPath else {
            return
        }
        
        var broadcast: Broadcast
        if indexPath.section == 0 {
            broadcast = liveBroadcasts[indexPath.row]
        } else {
            broadcast = archivedBroadcasts[indexPath.row]
        }
        
        if let controller = segue.destination as? BroadcastViewController {
            controller.broadcast = broadcast
        }
    }

    // MARK: UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return liveBroadcasts.count
        } else {
            return archivedBroadcasts.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Live Broadcasts"
        } else {
            return "Archived Broadcasts"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var broadcast: Broadcast
        if indexPath.section == 0 {
            broadcast = liveBroadcasts[indexPath.row]
        } else {
            broadcast = archivedBroadcasts[indexPath.row]
        }
        cell.textLabel?.text = broadcast.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "BroadcastSegue", sender: indexPath)
    }
    
    // MARK: Private
    
    private func loadBroadcasts() {
        guard channelId != "YOUR_CHANNEL_ID" else {
            fatalError("Set channelId at the top of this file to load valid broadcasts.")
        }
        
        BoxCastClient.shared.getLiveBroadcasts(channelId: channelId) { liveBroadcasts, error in
            if let liveBroadcasts = liveBroadcasts {
                self.liveBroadcasts = liveBroadcasts
                self.tableView.reloadData()
            } else {
                print("error loading live broadcasts: \(error!.localizedDescription)")
            }
        }

        BoxCastClient.shared.getArchivedBroadcasts(channelId: channelId) { archivedBroadcasts, error in
            if let archivedBroadcasts = archivedBroadcasts {
                self.archivedBroadcasts = archivedBroadcasts
                self.tableView.reloadData()
            } else {
                print("error loading archived broadcasts: \(error!.localizedDescription)")
            }
        }
    }
}

