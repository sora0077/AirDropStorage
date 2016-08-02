//
//  AppDelegate.swift
//  AirDropStorage
//
//  Created by 林達也 on 2016/08/02.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [String : AnyObject] = [:]) -> Bool {
        print(url, options)
        guard
            let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
            let filename = url.lastPathComponent else {
            return true
        }
        do {
//            let inbox = try url.deletingLastPathComponent()
            let to = try URL(fileURLWithPath: directory, isDirectory: true).appendingPathComponent(filename)
            if let path = to.path, FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(at: to)
            }
            try FileManager.default.moveItem(at: url, to: to)
            try (to as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
//            try FileManager.default.removeItem(at: inbox)
        } catch {
            print(error)
        }
        return true
    }

}

