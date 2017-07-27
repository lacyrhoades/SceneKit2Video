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
    static func saveVideo(at url: URL) {
        assert(FileUtil.fileExists(at: url), "Check for file output")
        
        DispatchQueue.global(qos: .utility).async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { (done, err) in
                if err != nil {
                    print("Tried to save video at path: ".appending(url.path))
                    print("Error creating video file in library")
                    print(err?.localizedDescription as Any)
                } else {
                    print("Done writing asset to the user's photo library")
                }
            }
        }
    }
}
