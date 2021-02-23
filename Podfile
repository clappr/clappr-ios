use_frameworks!
inhibit_all_warnings!

$iOS_version = '11.0'
$tvOS_version = '11.0'

def platform_iOS
  platform :ios, $iOS_version
end

def platform_tvOS
  platform :tvos, $tvOS_version
end

def shared_test_pods
  pod 'Quick', '2.2.0'
  pod 'Nimble', '8.0.7'
  pod 'OHHTTPStubs', '8.0.0'
  pod 'OHHTTPStubs/Swift', '8.0.0'
  pod 'Swifter', '1.5.0'
end

target 'Clappr' do
  # Pods for Clappr
  platform_iOS

  target 'Clappr_Tests' do
    # Pods for testing
    platform_iOS
    shared_test_pods
  end

  target 'Clappr_UITests' do
    # Pods for testing
    platform_iOS
    shared_test_pods
  end
end

target 'Clappr_Example' do
    # Pods for Clappr_Example
    platform_iOS
end

target 'Clappr_tvOS' do
    # Pods for Clappr_tvOS
    platform_tvOS

  target 'Clappr_tvOS_Tests' do
    # Pods for testing
    platform_tvOS
    shared_test_pods
  end
end

target 'Clappr_tvOS_Example' do
  # Pods for Clappr_tvOS_Example
  platform_tvOS
end
