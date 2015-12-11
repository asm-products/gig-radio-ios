# Uncomment this line to define a global platform for your project
# platform :ios, "6.0"
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
target "GigRadio" do
  pod 'RealmSwift', '~> 0.96'
  pod 'CLLocationManager-blocks', '~> 1.3'
  pod 'CMDQueryStringSerialization', '~> 0.3'
  pod 'YLMoment', '~> 0.5'
  pod 'Functional.m', '~> 1.0'
  pod 'UIActionSheet+Blocks', '~> 0.8'
  pod 'CocoaLumberjack', '~> 1.8'
  pod 'HTCoreImage', '~> 1.0'
  pod 'UIImage+RTTint', '~> 1.0'
  pod 'SimpleMotionEffects', '~> 1.0'
  pod 'CWLSynthesizeSingleton', '~> 1.0'
  pod 'AVHexColor', '~> 1.1.0'
  pod 'SVProgressHUD'
  pod 'IFTTTLaunchImage'
  pod 'SwiftyJSON'
  pod 'TWRDownloadManager', '~> 1.1'
  pod 'CryptoSwift'
  pod 'TMCache', '~> 2.1'
  pod 'StreamingKit', '~> 0.1'
  pod 'NSDictionary+TRVSUnderscoreCamelCaseAdditions', '~> 0.1'
end

target "GigRadioTests" do

end

# copy in acknowledgments
post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-GigRadio/Pods-GigRadio-Acknowledgements.plist', 'GigRadio/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
