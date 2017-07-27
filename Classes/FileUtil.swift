//
//  FileUtil.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation

class FileUtil {
    
    @discardableResult class func removeFile(at url: URL) -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch {
                print("Problem with deleting file in FileUtil ".appending(url.path))
                return false
            }
        }
        
        return true
    }
    
    @discardableResult class func mkdirUsingFile(at url: URL) -> Bool {
        let dirPath = url.deletingLastPathComponent().path
        let manager = FileManager.default
        if manager.fileExists(atPath: dirPath) == false {
            do {
                print("Creating directory at: ".appending(dirPath))
                try manager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Problem creating directory at: ".appending(dirPath))
                return false
            }
        }
        
        return true
    }
    
    static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static var tempFileDirectory: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("SceneKit2Video")
    }
    
    static var newTempFileURL: URL {
        return tempFileDirectory.appendingPathComponent(String(format: "%@.mp4", UUID().uuidString))
    }
}
