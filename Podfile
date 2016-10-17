platform :ios, '8.4'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

project 'Clappr.xcodeproj'

target 'Clappr_Tests' do
  pod 'Quick', '~> 0.9.3'
  pod 'Nimble', '~> 4.1.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
