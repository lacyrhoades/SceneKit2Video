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
    public var overlayImage: UIImage?
    
    public init() {
        
    }
}

public typealias IsDone = () -> (Bool)
public typealias Cleanup = () -> ()
public typealias RenderDone = (_: URL, _: @escaping Cleanup) -> ()

public class VideoRenderer {
    public weak var delegate: VideoRendererDelegate?
    
    public init() {

    }
    
    private static var renderQueue = DispatchQueue(label: "net.colordeaf.SceneKit2Video.RenderQueue")
    private static let renderSemaphore = DispatchSemaphore(value: 3)
    
    private let frameQueue = DispatchQueue(label: "net.colordeaf.SceneKit2Video.RenderFrames")

    public func render(scene: SCNScene, withOptions options: VideoRendererOptions, until: @escaping IsDone, andThen: @escaping RenderDone ) {

        VideoRenderer.renderQueue.async {
            VideoRenderer.renderSemaphore.wait()
            self.doRender(scene: scene, withOptions: options, until: until) {
                url in
                VideoRenderer.renderSemaphore.signal()
                andThen(url) {
                    FileUtil.removeFile(at: url)
                }
            }
        }
    }
    
    public func doRender(scene: SCNScene, withOptions options: VideoRendererOptions, until: @escaping () -> (Bool), andThen: @escaping (_: URL) -> () ) {
        let videoSize = options.videoSize
        let fps: Int32 = Int32(options.fps)
        let intervalDuration = CFTimeInterval(1.0 / Double(fps))
        let timescale: Float = 600
        let kTimescale: Int32 = Int32(timescale)
        let frameDuration = CMTimeMake(
            Int64( floor(timescale / Float(options.fps)) ),
            kTimescale
        )
        
        var frameNumber = 0
        var totalFrames: Int?
        if let totalTime = options.sceneDuration {
            totalFrames = Int(fps) * Int(ceil(totalTime))
        }
        
        let renderer = SCNRenderer(device: nil, options: nil)
        renderer.scene = scene
        renderer.autoenablesDefaultLighting = true
        
        let url = FileUtil.newTempFileURL
    
        if FileUtil.fileExists(at: url) {
            FileUtil.removeFile(at: url)
        } else {
            FileUtil.mkdirUsingFile(at: url)
        }
    
        var assetWriter: AVAssetWriter
        do {
            assetWriter = try AVAssetWriter(outputURL: url, fileType: .m4v)
        } catch {
            assert(false, error.localizedDescription)
            return
        }
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
    
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        // input.expectsMediaDataInRealTime = false
        assetWriter.add(input)
        
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: videoSize.width,
            kCVPixelBufferHeightKey as String: videoSize.height
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: attributes
        )
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: kCMTimeZero)
        
        input.requestMediaDataWhenReady(on: self.frameQueue, using: {
            
            if until() {
                input.markAsFinished()
                assetWriter.finishWriting {
                    DispatchQueue.main.async {
                        andThen(url)
                    }
                    return
                }
            } else if input.isReadyForMoreMediaData, let pool = pixelBufferAdaptor.pixelBufferPool {
                let snapshotTime = CFTimeInterval(intervalDuration * CFTimeInterval(frameNumber))
                let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNumber))
                var image = renderer.snapshot(atTime: snapshotTime, with: videoSize, antialiasingMode: SCNAntialiasingMode.multisampling4X)
                
                if let overlay = options.overlayImage {
                    image = image.imageByOverlaying(overlay)
                }
                
                let pixelBuffer = VideoRenderer.pixelBuffer(withSize: videoSize, fromImage: image, usingBufferPool: pool)
                pixelBufferAdaptor.append(
                    pixelBuffer,
                    withPresentationTime: presentationTime
                )
                
                frameNumber += 1
                
                self.delegate?.videoRenderer(createdNewImage: image)
                if let totalFrames = totalFrames {
                    self.delegate?.videoRenderer(
                        progressUpdated: min(1, Float(frameNumber)/Float(totalFrames))
                    )
                }
            } else if input.isReadyForMoreMediaData {
                warn("VideoRenderer", String(format: "Input ready, no pixel buffer pool: %d", scene.hash))
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
