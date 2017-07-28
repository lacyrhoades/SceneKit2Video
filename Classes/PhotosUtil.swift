//
//  PhotosUtil.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation
import Photos

class PhotosUtil {
    static let saveQueue = DispatchQueue(label: "net.colordeaf.SceneKit2Video.SaveVideos")
    
    static func saveVideo(at url: URL, andThen: @escaping () -> ()) {
        assert(FileUtil.fileExists(at: url), "Check for file output!")
        
        PhotosUtil.saveQueue.async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { (done, err) in
                if err != nil {
                    log("PhotosUtil", "Tried (and failed) to save video at path: ".appending(url.path))
                    log("PhotosUtil", "Error creating video file in library: ".appending(err?.localizedDescription ?? "None"))
                } else {
                    log("PhotosUtil", "Done writing asset to the user's library")
                }
                
                andThen()
            }
        }
    }
}
