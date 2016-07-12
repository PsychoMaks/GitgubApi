//
//  BaseViewController.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/11/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import UIKit
import WillowTreeReachability
import Whisper

class BaseViewController: UINavigationController, NetworkStatusSubscriber {
    
    var reachability: Monitor?
    var reachabilitySubscription: NetworkStatusSubscription?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.reachability == nil {
            self.reachability = Monitor()
            self.reachability?.startMonitoring()
            self.reachabilitySubscription = self.reachability?.addReachabilitySubscriber(self)
        }
        
    }
    
    deinit {
        self.reachability?.stopMonitoring()
    }
    
    func networkStatusChanged(status: ReachabilityStatus) {
        dispatch_async(dispatch_get_main_queue()) {
            switch status {
            case .NotReachable:
                self.showNotification(Message(title: NSLocalizedString("Not reachable", comment: ""), textColor: UIColor.whiteColor(), backgroundColor: UIColor(red:0.99, green:0.44, blue:0.47, alpha:1.0), images:nil ))
            case .ViaWifi, .ViaCellular:
                self.showNotification(Message(title: NSLocalizedString("Reachable", comment: ""), textColor:UIColor.whiteColor(), backgroundColor: UIColor(red:0.54, green:0.87, blue:0.43, alpha:1.0), images:nil ))
            default:
                self.showNotification(Message(title: NSLocalizedString("Connection problems", comment: ""), textColor: UIColor.whiteColor(), backgroundColor: UIColor.lightGrayColor(), images:nil ))
            }
            
        }
        
    }
    
    func showNotification(message: Message) {
        Whisper(message, to: self, action: .Show)
    }


    
}
