//
//  UIImage+VideoRender.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 9/29/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

extension UIImage {
    func imageByOverlaying(_ overlay: UIImage) -> UIImage {
        let size = self.size
        let overlaySize = overlay.size
        
        var scale: CGFloat
        if size.height > size.width {
            scale = size.width / overlaySize.width
        } else {
            scale = size.height / overlaySize.height
        }
        
        let scaledSize = CGSize(width: overlaySize.width * scale, height: overlaySize.height * scale)
        
        let xOffset = (size.width - scaledSize.width) / 2.0
        let yOffset = (size.height - scaledSize.height) / 2.0
        
        let selfRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let scaledOverlayRect = CGRect(x: xOffset, y: yOffset, width: scaledSize.width, height: scaledSize.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale);
        self.draw(in: selfRect)
        overlay.draw(in: scaledOverlayRect)
        let maybeResult = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let result = maybeResult else {
            assert(false, "Unable to create overlayed image")
            return self
        }
        
        return result
    }
}
