//
//  ViewController.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SceneKit2Video.Logger.isEnabled = true
        
        let scene = DemoCubeScene(rotations: 2) // any SCNScene object or subclass
        self.renderScene(scene: scene, withDelegate: self) // Renders while showing output on self.view
        
        for r in 2...10 {
            // You can also render arbitrary scenes in the background
            let scene = DemoCubeScene(rotations: r)
            self.renderScene(scene: scene)
        }
    }
    
    func renderScene(scene: DemoCubeScene, withDelegate delegate: VideoRendererDelegate? = nil) {
        var options = VideoRendererOptions()
        options.sceneDuration = scene.duration
        options.videoSize = CGSize(width: 1280, height: 720)
        options.fps = 60
        
        let startTime = Date()
        log(
            "ViewController",
            String(format: "Starting render: %d", scene.hash)
        )
        
        let videoRenderer = VideoRenderer()
        videoRenderer.delegate = delegate
        videoRenderer.render(
            scene: scene,
            withOptions: options,
            until: {
                return scene.isDone
            },
            andThen: {
                outputURL, cleanupFiles in
                
                log("ViewController",
                    String(
                        format:"Finished render of %d in time: %.2fs",
                        scene.hash,
                        startTime.timeIntervalSinceNow * -1
                    )
                )
                
                PhotosUtil.saveVideo(at: outputURL, andThen: {
                    // I'm done with the video file now
                    cleanupFiles()
                })
                
                if self.presentedViewController == nil {
                    let alert = UIAlertController(title: "Done", message: "A new video has been added to the Camera Roll", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        )
    }
}

extension ViewController: VideoRendererDelegate {
    func videoRenderer(createdNewImage image: UIImage) {
        DispatchQueue.main.async {
            self.imageView?.image = image
        }
    }
    
    func videoRenderer(progressUpdated to: Float) {
        // log("VideoRenderer", to)
    }
}
