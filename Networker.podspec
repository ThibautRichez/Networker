Pod::Spec.new do |spec|
  spec.name         = "Networker"
  spec.version      = "1.0.0"
  spec.summary      = "A lightweight network library for Swift."
  spec.homepage     = "https://github.com/ThibautRichez/Networker"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Thibaut Richez" => "thibautrichez@hotmail.fr" }
  spec.swift_version = '5.3'

  spec.ios.deployment_target = "12.0"
  spec.osx.deployment_target = "10.11"
  spec.watchos.deployment_target = "4.0"
  spec.tvos.deployment_target = "11.0"

  spec.source       = { :git => "https://github.com/ThibautRichez/Networker.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/Networker/**/*.swift"
end
