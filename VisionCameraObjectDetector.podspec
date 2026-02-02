require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "VisionCameraObjectDetector"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"] || "https://github.com/evrimuysal/vision-camera-object-detector"
  s.license      = package["license"] || "MIT"
  s.authors      = package["author"] || "Evrim Uysal"

  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/evrimuysal/vision-camera-object-detector.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.public_header_files = "ios/VisionCameraObjectDetector.h"
  s.swift_version = "5.0"
  s.module_name = "VisionCameraObjectDetector"

  # React Native dependency
  s.dependency "React-Core"

  # VisionCamera dependency
  s.dependency "VisionCamera"

  # MLKit Object Detection
  s.dependency "GoogleMLKit/ObjectDetection", "~> 6.0.0"

  # Static framework required for MLKit
  s.static_framework = true
end
