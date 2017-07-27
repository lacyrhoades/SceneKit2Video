# SceneKit2Video
Demo project: High-def video output from SceneKit

![Video files from SceneKit scenes](/README.png)

    var options = VideoRendererOptions()
    options.videoSize = CGSize(width: 1280, height: 720)
    options.fps = 60

    self.videoRenderer.render(
        scene: SceneKitScene,
        withOptions: options,
        until: {
            return self.rotations >= self.totalRotations
        },
        andThen: {
            outputPath in
            print("Video file at: ".appending(outputPath))
        }
    )
