//
//  UIImage+VideoRender.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 9/29/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

extension UIImage {
    func imageByOverlaying(image: UIImage) -> UIImage {
        let selfRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext( self.size );
        self.draw(in: selfRect);
        image.draw(in: selfRect, blendMode: .normal, alpha: 1.0)
        let maybeResult = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        guard let result = maybeResult else {
            assert(false, "Unable to create overlayed image")
            return self
        }
        
        return result
    }
}
