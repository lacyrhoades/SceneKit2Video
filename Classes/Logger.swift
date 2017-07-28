//
//  Logger.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 7/28/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation

class Logger {
    static var isEnabled: Bool = false
}

func log(_ namespace: String, _ message: String) {
    if Logger.isEnabled {
        print(String(format: "%@: %@", namespace, message))
    }
}

func warn(_ namespace: String, _ message: String) {
    print(String(format: "%@: %@", namespace, message))
}
