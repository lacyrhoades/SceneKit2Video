//
//  AppDelegate.swift
//  SCNKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let photos = PHPhotoLibrary.authorizationStatus()
        
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                print(status)
            })
        }
        
        return true
    }

}

