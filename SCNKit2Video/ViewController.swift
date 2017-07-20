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
    
    // Image view to preview each 3d render frame
    // Not required to create a video file
    @IBOutlet var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScene()
        
        self.renderScene()
    }
    
    var rotations: Int = 0
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var cameraBoxNode: SCNNode!
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
        
        self.cameraNode = SCNNode()
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.camera?.zNear = 0
        self.cameraNode.camera?.zFar = 1000
        self.cameraNode.position = SCNVector3Make(0, 0, 0)
        self.cameraNode.eulerAngles = SCNVector3Make(0.0, 0.0, 0.0)
        
        self.cameraBoxNode = SCNNode()
        self.cameraBoxNode.addChildNode(self.cameraNode)
        scene.rootNode.addChildNode(self.cameraBoxNode)
        
        self.cameraBoxNode.runAction(
            SCNAction.repeatForever(
                SCNAction.sequence(
                    [
                        SCNAction.rotateBy(x: 0.0, y: -2 * CGFloat.pi, z: 0.0, duration: 12.0),
                        SCNAction.run({ (node) in
                            print("DONE")
                            self.rotations += 1
                        })
                    ]
                )
            )
        )
    }
    
    func renderScene() {
        self.videoRenderer.delegate = self
        
        self.videoRenderer.render(
            scene: self.scene,
            until: {
                return self.rotations > 0
        },
            andThen: {
                outputPath in
                
                PhotosUtil.saveVideo(atPath: outputPath)
                
                let alert = UIAlertController(title: "Done", message: "Video has been created at ".appending(outputPath), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    //
                }))
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
        print(to)
    }
}
