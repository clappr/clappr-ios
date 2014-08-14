#
# Be sure to run `pod lib lint Clappr.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Clappr"
  s.version          = "0.1.0"
  s.summary          = "An extensible Media Player for iOS"
  s.description      = <<-DESC
                       An optional longer description of Clappr

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/globocom/clappr-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "thiagopnts" => "thiagopnts@gmail.com" }
  s.source           = { :git => "https://github.com/globocom/clappr-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{m,h}'
  s.resources = 'Pod/Assets/*.{xib,png}'

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
