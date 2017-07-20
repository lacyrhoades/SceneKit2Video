//
//  ViewController.swift
//  SCNKit2Video
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
        redMaterial.reflective.contents = UIColor.red
        let greenMaterial = SCNMaterial()
        greenMaterial.emission.contents = UIColor.green
        let blueMaterial = SCNMaterial()
        blueMaterial.reflective.contents = UIColor.blue
        let yellowMaterial = SCNMaterial()
        yellowMaterial.reflective.contents = UIColor.yellow
        
        let cube = SCNBox(width: 35, height: 35, length: 35, chamferRadius: 1.0)
        cube.materials = [greenMaterial]
        let cubeGeometryNode = SCNNode(geometry: cube)
        cubeGeometryNode.eulerAngles = SCNVector3Make(0.0, 1.0, 0.0)
        cubeGeometryNode.position = SCNVector3Make(100.0, 0.0, 0.0)
        scene.rootNode.addChildNode(cubeGeometryNode)
        
        let cylinder = SCNCylinder(radius: 8, height: 20)
        cylinder.materials = [redMaterial]
        let cylinderGeometryNode = SCNNode(geometry: cylinder)
        cylinderGeometryNode.eulerAngles = SCNVector3Make(1.0, 1.0, 2.0)
        cylinderGeometryNode.position = SCNVector3Make(0.0, 0.0, 70.0)
        scene.rootNode.addChildNode(cylinderGeometryNode)
        
        let torus = SCNTorus(ringRadius: 43.0, pipeRadius: 3.0)
        torus.materials = [blueMaterial]
        let torusGeometryNode = SCNNode(geometry: torus)
        torusGeometryNode.position = SCNVector3Make(0.0, 0.0, -100.0)
        torusGeometryNode.eulerAngles = SCNVector3Make(Float.pi / 2.0, 0.0, 0.0)
        scene.rootNode.addChildNode(torusGeometryNode)
        
        let sphere = SCNSphere(radius: 25.0)
        sphere.materials = [yellowMaterial]
        let sphereGeometryNode = SCNNode(geometry: sphere)
        sphereGeometryNode.position = SCNVector3Make(-100.0, 0.0, 0.0)
        scene.rootNode.addChildNode(sphereGeometryNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 0
        cameraNode.camera?.zFar = 1000
        cameraNode.position = SCNVector3Make(0, 0, 0)
        cameraNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0)
        
        let cameraBoxNode = SCNNode()
        cameraBoxNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraBoxNode)
        
        cameraBoxNode.runAction(
            SCNAction.repeatForever(
                SCNAction.sequence(
                    [
                        SCNAction.rotateBy(x: 0.0, y: -2 * CGFloat.pi, z: 0.0, duration: self.rotationDuration),
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
        
        let options = VideoRendererOptions(
            sceneDuration: self.rotationDuration * TimeInterval(self.totalRotations),
            videoSize: CGSize(width: 1280, height: 720),
            fps: 60
        )
        
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
