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
                log("FileUtil", "Problem with deleting file in FileUtil ".appending(url.path))
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
                log("FileUtil", "Creating directory at: ".appending(dirPath))
                try manager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log("FileUtil", "Problem creating directory at: ".appending(dirPath))
                return false
            }
        }
        
        return true
    }
    
    class func cleanDir(at url: URL) {
        let dirPath = url.path
        let manager = FileManager.default
    
        var contents: [String] = []
        
        do {
            contents = try manager.contentsOfDirectory(atPath: dirPath)
        } catch {
            log("FileUtil", "Cleanup failed, can't get contents of dir: ".appending(dirPath))
            do {
                log("FileUtil", "Creating dir ".appending(dirPath))
                try manager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                log("FileUtil", "Could not create dir")
            }
            
            return
        }
        
        for file in contents {
            let filepath = String(format: "%@/%@", dirPath, file)
            
            do {
                try manager.removeItem(atPath: filepath)
                log("FileUtil", "Removed old file: ".appending(file))
            } catch {
                log("FileUtil", "Trouble removing old file: ".appending(filepath))
            }
        }
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
