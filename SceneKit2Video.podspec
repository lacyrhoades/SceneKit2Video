Pod::Spec.new do |s|
  s.name             = 'SceneKit2Video'
  s.version          = '0.1'
  s.summary          = 'Render SceneKit scenes to video files'

  s.description      = <<-DESC
SceneKit2Video takes you super high-level SceneKit objects and turns it into a video of arbitrary
dimensions without having to capture OpenGL frames or render in real time. You can render video
files "headless" in the background and save them to the camera roll, or wherever you want to go
from there.
                       DESC

  s.homepage         = 'https://github.com/lacyrhoades/SceneKit2Video'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lacy Rhoades' => 'lacyrhoades@gmail.com' }
  s.source           = { :git => 'https://github.com/lacyrhoades/SceneKit2Video.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lacyrhoades'

  s.ios.deployment_target = '9.3'

  s.source_files = 'Classes/**/*'
end
