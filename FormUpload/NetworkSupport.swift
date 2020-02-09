//
//  NetworkSupport.swift
//  FormUpload
//
//  Created by Lauren White on 2/7/20.
//  Copyright © 2020 Lauren White. All rights reserved.
//

import Foundation
import Network


extension Notification.Name {
    static let networkConnected = Notification.Name("newtorkConnected")
    static let noNetworkConnected = Notification.Name("noNetworkConnected")
}


class NetworkSupport {
    
    static let monitor = NWPathMonitor()
    static let queue = DispatchQueue(label: "Monitor")
    
    private static var sharedNetworkSupport: NetworkSupport = {
        let networkSupport = NetworkSupport()
        
        // Configuration
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                NotificationCenter.default.post(name: .networkConnected, object: nil)
                print("We're connected!")
            } else if (path.status == .requiresConnection) {
                print("????")
            } else {
                NotificationCenter.default.post(name: .noNetworkConnected, object: nil)
                print("No connection.")
            }
        }
        monitor.start(queue: queue)
    
        return networkSupport
    }()
    
    class func shared() -> NetworkSupport {
        return sharedNetworkSupport
    }
}
