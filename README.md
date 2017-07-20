# SCNKit2Video
Demo project: High-def video output from SCNKit

    var options = VideoRendererOptions()
    options.videoSize = CGSize(width: 1280, height: 720)
    options.fps = 60

    self.videoRenderer.render(
        scene: scnKitScene,
        withOptions: options,
        until: {
            return self.rotations >= self.totalRotations
        },
        andThen: {
            outputPath in
            print("Video file at: ".appending(outputPath))
        }
    )
