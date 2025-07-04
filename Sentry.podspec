Pod::Spec.new do |s|
  s.name         = "Sentry"
  s.version      = "8.53.1"
  s.summary      = "Sentry client for cocoa"
  s.homepage     = "https://github.com/getsentry/sentry-cocoa"
  s.license      = "mit"
  s.authors      = "Sentry"
  s.source       = { :git => "https://github.com/getsentry/sentry-cocoa.git",
                     :tag => s.version.to_s }

  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.tvos.deployment_target = "11.0"
  s.watchos.deployment_target = "4.0"
  s.visionos.deployment_target = "1.0"
  s.module_name  = "Sentry"
  s.requires_arc = true
  s.frameworks = 'Foundation'
  s.swift_versions = "5.5"
  s.pod_target_xcconfig = {
      'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES',
      'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',
      'CLANG_CXX_LIBRARY' => 'libc++',
      # APPLICATION_EXTENSION_API_ONLY has a side effect of exposing all `@objc` marked entities in `Sentry-Swift.h` (regardless of access level)
      # This is currently needed for Sentry module to compile. Changing this to NO will break the build.
      'APPLICATION_EXTENSION_API_ONLY' => 'YES',
      'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/Sources/Sentry/include',
      'OTHER_CFLAGS' => '$(inherited) -DAPPLICATION_EXTENSION_API_ONLY_$(APPLICATION_EXTENSION_API_ONLY)'
  }
  s.watchos.pod_target_xcconfig = {
      'OTHER_LDFLAGS' => '$(inherited) -framework WatchKit'
  }

  s.default_subspecs = ['Core']

  s.subspec 'Core' do |sp|
      sp.source_files = "Sources/Sentry/**/*.{h,hpp,m,mm,c,cpp}",
        "Sources/SentryCrash/**/*.{h,hpp,m,mm,c,cpp}", "Sources/Swift/**/*.{swift,h,hpp,m,mm,c,cpp}"
      sp.preserve_path = "Sources/Sentry/include/module.modulemap"
      sp.public_header_files =
        "Sources/Sentry/Public/*.h"
        
      sp.preserve_path = "Sources/Sentry/include/module.modulemap"
      sp.resource_bundles = { "Sentry" => "Sources/Resources/PrivacyInfo.xcprivacy" }
  end
  
  s.subspec 'HybridSDK' do |sp|
      sp.source_files = "Sources/Sentry/**/*.{h,hpp,m,mm,c,cpp}",
        "Sources/SentryCrash/**/*.{h,hpp,m,mm,c,cpp}", "Sources/Swift/**/*.{swift,h,hpp,m,mm,c,cpp}"
    
      sp.preserve_path = "Sources/Sentry/include/module.modulemap"
      sp.public_header_files =
        "Sources/Sentry/Public/*.h", "Sources/Sentry/include/HybridPublic/*.h"

      sp.preserve_path = "Sources/Sentry/include/module.modulemap"
      sp.resource_bundles = { "Sentry" => "Sources/Resources/PrivacyInfo.xcprivacy" }
  end
end
