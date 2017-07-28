# SceneKit2Video
Demo project: High-def video output from SceneKit

![Video files from SceneKit scenes](/README.png)

## Podfile

    pod 'SceneKit2Video', :git => 'git@github.com:lacyrhoades/SceneKit2Video.git'

## Example

    var options = VideoRendererOptions()
    options.videoSize = CGSize(width: 1280, height: 720)
    options.fps = 60

    let videoRenderer = VideoRenderer()
    videoRenderer.render(
        scene: sceneKitScene,
        withOptions: options,
        until: {
            return self.rotations >= self.totalRotations
        },
        andThen: {
            outputURL, cleanup in
            print("Video file at: ".appending(outputURL.path))
            cleanup() // when you're done with the file
        }
    )
