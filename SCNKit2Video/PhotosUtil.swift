//
//  PhotosUtil.swift
//  SCNKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import Foundation
import Photos

class PhotosUtil {
    static func saveVideo(atPath path: String) {
        assert(FileUtil.fileExists(atPath: path), "Check for file output")
        
        DispatchQueue.global(qos: .utility).async {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
            }) { (done, err) in
                if err != nil {
                    print("Error creating video file in library")
                    print(err.debugDescription)
                } else {
                    print("Done writing asset to the user's photo library")
                }
            }
        }
    }
}
