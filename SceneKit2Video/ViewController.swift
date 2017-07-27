//
//  ViewController.swift
//  SceneKit2Video
//
//  Created by Lacy Rhoades on 7/20/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import SceneKit

class ViewController: UIViewController {
    
    var videoRenderer = VideoRenderer()
    
    var rotations: Int = 0
    let totalRotations: Int = 1
    var rotationDuration: TimeInterval = 12.0
    
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScene()
        
        self.renderScene()
    }
    
    var scene: SCNScene!
    func setupScene() {
        self.scene = SCNScene()
        self.scene.background.contents = UIColor.black
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        redMaterial.specular.contents = UIColor.white
        
        let cube = SCNBox(width: 35, height: 35, length: 35, chamferRadius: 0)
        cube.materials = [redMaterial]
        let cubeGeometryNode = SCNNode(geometry: cube)
        cubeGeometryNode.position = SCNVector3Make(0.0, 0.0, -75.0)
        scene.rootNode.addChildNode(cubeGeometryNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0)
        
        let cameraBoxNode = SCNNode()
        cameraBoxNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraBoxNode)
        
        cubeGeometryNode.runAction(
            SCNAction.repeatForever(
                SCNAction.sequence(
                    [
                        SCNAction.rotateBy(x: 0.0, y: 2 * CGFloat.pi, z: 2 * CGFloat.pi, duration: self.rotationDuration),
                        SCNAction.run({ (node) in
                            self.rotations += 1
                        })
                    ]
                )
            )
        )
    }
    
    func renderScene() {
        
        self.videoRenderer.delegate = self
        
        var options = VideoRendererOptions()
        options.sceneDuration = self.rotationDuration * TimeInterval(self.totalRotations)
        options.videoSize = CGSize(width: 1280, height: 720)
        options.fps = 60
        
        let startTime = Date()
        self.videoRenderer.render(
            scene: self.scene,
            withOptions: options,
            until: {
                return self.rotations >= self.totalRotations
            },
            andThen: {
                outputPath in
                
                print(
                    String(format:"Finished render in time: %.2fs", startTime.timeIntervalSinceNow * -1)
                )
                
                PhotosUtil.saveVideo(atPath: outputPath)
                
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
    
    func videoRenderer(pogressUpdated to: Float) {
        // print(to)
    }
}
