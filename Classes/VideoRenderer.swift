//
//  VideoRenderer.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import SceneKit
import AVFoundation

public protocol VideoRendererDelegate: class {
    func videoRenderer(createdNewImage image: UIImage)
    func videoRenderer(progressUpdated to: Float)
}

public struct VideoRendererOptions {
    public var sceneDuration: TimeInterval?
    public var videoSize = CGSize(width: 1280, height: 720)
    public var fps: Int = 60
    
    public init() {
        
    }
}

public class VideoRenderer {
    public init() {
    
    }
    
    public weak var delegate: VideoRendererDelegate?
    
    var renderer: SCNRenderer!
    
    private var frameNumber: Int = 0
    
    private var scene: SCNScene?
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    
    public func render(scene: SCNScene, withOptions options: VideoRendererOptions, until: @escaping () -> (Bool), andThen: @escaping (_: URL) -> () ) {
        
        let videoSize = options.videoSize
        
        let fps: Int32 = Int32(options.fps)
        let intervalDuration = CFTimeInterval(1.0 / Double(fps))
        let kTimescale: Int32 = 600
        let frameDuration = CMTimeMake(Int64(kTimescale / fps), kTimescale)
        
        self.frameNumber = 0
        var totalFrames: Int?
        if let totalTime = options.sceneDuration {
            totalFrames = Int(fps) * Int(ceil(totalTime))
        }
        
        self.renderer = SCNRenderer(device: nil, options: nil)
        self.renderer.scene = scene
        self.renderer.autoenablesDefaultLighting = true
        
        let url = FileUtil.newTempFileURL
        
        FileUtil.removeFile(at: url)
        
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
        
        guard let input = self.assetWriterInput else {
            fatalError("Could not create asset writer input")
        }
        
        input.expectsMediaDataInRealTime = false
        self.assetWriter?.add(input)
        
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: videoSize.width,
            kCVPixelBufferHeightKey as String: videoSize.height
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
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
                        andThen(url)
                    }
                    return
                }
            } else if self.assetWriterInput?.isReadyForMoreMediaData ?? false {
                guard let pool = pixelBufferAdaptor.pixelBufferPool else {
                    fatalError("Could not get a pixel buffer pool")
                }
                
                let snapshotTime = CFTimeInterval(intervalDuration * CFTimeInterval(self.frameNumber))
                let presentationTime = CMTimeMultiply(frameDuration, Int32(self.frameNumber))
                let image = self.renderer.snapshot(atTime: snapshotTime, with: videoSize, antialiasingMode: SCNAntialiasingMode.multisampling4X)
                let pixelBuffer = VideoRenderer.pixelBuffer(withSize: videoSize, fromImage: image, usingBufferPool: pool)
                pixelBufferAdaptor.append(
                    pixelBuffer,
                    withPresentationTime: presentationTime
                )
                
                self.frameNumber += 1
                
                self.delegate?.videoRenderer(createdNewImage: image)
                if let totalFrames = totalFrames {
                    self.delegate?.videoRenderer(
                        progressUpdated: min(1, Float(self.frameNumber)/Float(totalFrames))
                    )
                }
            }
        })
    }
    
    class func pixelBuffer(withSize size: CGSize, fromImage image: UIImage, usingBufferPool pool: CVPixelBufferPool) -> CVPixelBuffer {
        
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
            assert(false, "Could not create context from pixel buffer")
        }
        
        context?.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        return pixelBuffer
    }
}
