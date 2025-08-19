Pod::Spec.new do |s|
  s.name             = 'camera_native'
  s.version          = '1.0.0'
  s.summary          = 'Native camera module with XCFramework support'
  s.description      = <<-DESC
Advanced camera functionality with support for external XCFrameworks
                       DESC
  s.homepage         = 'https://github.com/superapp/camera_native'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'SuperApp Team' => 'team@superapp.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # External XCFrameworks
  s.vendored_frameworks = [
    'Frameworks/AdvancedCameraSDK.xcframework',
    'Frameworks/AIImageProcessor.xcframework',
    'Frameworks/CameraMLKit.xcframework'
  ]

  # System frameworks required by XCFrameworks
  s.frameworks = [
    'AVFoundation',
    'CoreImage',
    'CoreML',
    'Vision',
    'Photos',
    'UIKit'
  ]

  # Pod configuration
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
