Pod::Spec.new do |s|
  s.name = 'boxcast-sdk-apple'
  s.version = '0.2.0'
  s.license = 'MIT'
  s.summary = 'BoxCast is a SDK for integrating with the BoxCast API on Apple platforms.'
  s.homepage = 'https://github.com/boxcast/boxcast-sdk-apple'
  s.social_media_url = 'http://twitter.com/boxcast'
  s.authors = { 'Camden Fullmer' => 'camden.fullmer@boxcast.com' }

  s.source = { :git => 'https://github.com/boxcast/boxcast-sdk-apple.git', :tag => s.version }
  s.source_files = 'Source/**/*.swift'

  s.ios.deployment_target  = '9.0'
  s.osx.deployment_target  = '10.12'

  s.dependency 'Alamofire', '~> 4.4'
end
