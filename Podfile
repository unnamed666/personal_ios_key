source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def shared_pods
    pod 'Masonry', '~> 1.1.0'
    pod 'MBProgressHUD'
    pod 'SSZipArchive'
#   pod 'HMSegmentedControl', '~> 1.5.4'
#    pod 'SwiftTheme'


  pod 'SocketRocket'
  pod 'YYWebImage'
end

target 'PandaKeyboard' do
    pod 'YYImage'
#    pod 'YYWebImage'
#    pod 'SDWebImage'
    pod 'MJRefresh'
    pod 'lottie-ios', '~> 2.5.3'
    pod 'STPopup'
#    pod 'ZCAnimatedLabel'
    pod 'GoogleMobileVision/FaceDetector'
    pod 'AppsFlyerFramework'
    pod 'Bolts'
    pod 'FBSDKCoreKit'
    pod 'FBSDKShareKit'
    pod 'FBSDKLoginKit'
	shared_pods
end

target 'PandaKeyboard Extension' do
#    pod 'MagicalRecord', '~> 2.3.2'
	shared_pods
end

target 'iMessage' do
    pod 'YYWebImage'
end

target 'KeyboardKit' do
    pod 'CocoaLumberjack', '~> 3.2.1'
    pod 'UICKeyChainStore'
    pod 'AFNetworking'
    pod 'Fabric'
    pod 'Crashlytics'
    
end
