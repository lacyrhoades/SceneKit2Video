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
        
        // Renders while showing output on self.view
        // self.renderScene(withRotations: 1, withDelegate: self)
        
        // You can also render "headeless" in the background
        // self.renderScene(withRotations: 3)
    }
    
    func renderScene(withRotations rotations: Int, withDelegate delegate: VideoRendererDelegate? = nil) {
        let scene = DemoCubeScene(rotations: rotations) // any SCNScene object / subclass
        
        var options = VideoRendererOptions()
        options.sceneDuration = scene.duration
        options.videoSize = CGSize(width: 1280, height: 720)
        options.fps = 60
        
        let startTime = Date()
        
        let videoRenderer = VideoRenderer()
        videoRenderer.delegate = delegate
        videoRenderer.render(
            scene: scene,
            withOptions: options,
            until: {
                return scene.isDone
            },
            andThen: {
                outputURL in
                
                print(
                    String(format:"Finished render in time: %.2fs", startTime.timeIntervalSinceNow * -1)
                )
                
                PhotosUtil.saveVideo(at: outputURL)
                
                let alert = UIAlertController(title: "Done", message: "A new video has been added to the Camera Roll", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
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
        // print(to)
    }
}
