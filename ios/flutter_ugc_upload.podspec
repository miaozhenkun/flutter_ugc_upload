#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ugc_upload.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ugc_upload'
  s.version          = '0.0.1'
  s.summary          = 'flutter_ugc_upload'
  s.description      = <<-DESC
flutter_ugc_upload
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'QCloudQuic/Slim'
  s.dependency 'AFNetworking'
  s.static_framework = true
  s.frameworks = 'CoreTelephony','Foundation','SystemConfiguration'
  s.libraries = 'c++'
  s.platform = :ios, '11.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
