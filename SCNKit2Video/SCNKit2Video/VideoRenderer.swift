//
//  VideoRenderer.swift
//  SCNKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import SceneKit
import AVFoundation

let fps: Int32 = 60
let intervalDuration = CFTimeInterval(1.0 / Double(fps))

let kTimescale: Int32 = 600
let frameDuration = CMTimeMake(Int64(kTimescale / fps), kTimescale)

protocol VideoRendererDelegate: class {
    func videoRenderer(createdNewImage image: UIImage)
    func videoRenderer(pogressUpdated to: Float)
}

class VideoRenderer {
    weak var delegate: VideoRendererDelegate?
    
    var renderer: SCNRenderer!
    
    let videoSize = CGSize(width: 1280, height: 720)
    var ratio: CGFloat {
        return self.videoSize.width / self.videoSize.height
    }
    
    var frameNumber: Int = 0
    
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    func render(scene: SCNScene, until: @escaping () -> (Bool), andThen: @escaping (_: String) -> ()) {
        self.frameNumber = 0
        
        self.renderer = SCNRenderer(device: nil, options: nil)
        self.renderer.scene = scene
        self.renderer.autoenablesDefaultLighting = true
        
        let path = NSTemporaryDirectory().appending("tmp.mp4")
        let url = URL(fileURLWithPath: path)
        
        FileUtil.removeFile(atPath: path)
        
        do {
            self.assetWriter = try AVAssetWriter(outputURL: url, fileType: AVFileTypeAppleM4V)
        } catch {
            assert(false, error.localizedDescription)
        }
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
        
        self.assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: settings)
        
        if let input = self.assetWriterInput {
            self.assetWriter?.add(input)
            
            let attributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: videoSize.width,
                kCVPixelBufferHeightKey as String: videoSize.height
            ]
            
            self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: input,
                sourcePixelBufferAttributes: attributes
            )
            
            self.assetWriter?.startWriting()
            self.assetWriter?.startSession(atSourceTime: kCMTimeZero)
            
            self.assetWriterInput?.requestMediaDataWhenReady(on: DispatchQueue.global(), using: {
                if until() {
                    self.assetWriterInput?.markAsFinished()
                    self.assetWriter?.finishWriting {
                        DispatchQueue.main.async {
                            andThen(path)
                        }
                        return
                    }
                } else if self.assetWriterInput?.isReadyForMoreMediaData ?? false {
                    guard let pool = self.pixelBufferAdaptor?.pixelBufferPool else {
                        assert(false, "Could not get a pixel buffer pool")
                        return
                    }
                    
                    let snapshotTime = CFTimeInterval(intervalDuration * CFTimeInterval(self.frameNumber))
                    let presentationTime = CMTimeMultiply(frameDuration, Int32(self.frameNumber))
                    let image = self.renderer.snapshot(atTime: snapshotTime, with: self.videoSize, antialiasingMode: SCNAntialiasingMode.multisampling4X)
                    let pixelBuffer = VideoRenderer.pixelBuffer(fromImage: image, usingBufferPool: pool, size: self.videoSize)
                    self.pixelBufferAdaptor?.append(
                        pixelBuffer,
                        withPresentationTime: presentationTime
                    )
                    self.frameNumber += 1
                    
                    self.delegate?.videoRenderer(createdNewImage: image)
                }
            })
        }
    }
    
    class func pixelBuffer(fromImage image: UIImage, usingBufferPool pool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
        
        var pixelBufferOut: CVPixelBuffer?
        
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBufferOut)
        
        if status != kCVReturnSuccess {
            fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
        }
        
        let pixelBuffer = pixelBufferOut!
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        let context = CGContext(
            data: data,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: Int(8),
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        if context == nil {
            assert(false, "could not create context from pixel buffer")
            return pixelBuffer
        }
        
        context?.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        return pixelBuffer
    }
}
