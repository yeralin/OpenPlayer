IOS_DEPLOYMENT_TARGET = '17.0'

platform :ios, IOS_DEPLOYMENT_TARGET
workspace 'MusicPlayer'
inhibit_all_warnings!

target 'MusicPlayer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'SwiftLint'
  pod 'SWRevealViewController'
  pod 'SwiftyBeaver'
  pod 'SwiftOverlays'
  pod 'Alamofire'
  pod 'GCDWebServer/WebUploader'
  pod 'CocoaLumberjack'
  pod 'BufferSlider'
  pod 'MobileVLCKit'

  # Unit tests are hosted in the app and `@testable import MusicPlayer`, so
  # they need the pods' module search paths (but must not link them twice).
  target 'MusicPlayerTests' do
    inherit! :search_paths
  end
end

target 'MusicPlayerUITests' do
  use_frameworks!
end

# Several pods declare iOS 8-10 as their minimum. Current Xcode cannot build
# for those versions (it no longer ships libarclite), so build every pod for
# the app's own deployment target instead.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
    end
  end
end
