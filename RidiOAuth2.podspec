Pod::Spec.new do |s|
  s.name         = 'RidiOAuth2'
  s.version      = '1.2.0'
  s.summary      = 'OAuth2 client library written in Swift for RIDI account authorization.'
  s.homepage     = 'https://github.com/ridi/cocoa-oauth2'
  s.authors      = { 'Ridibooks Viewer Team' => 'viewer.team@ridi.com' }
  s.license      = 'MIT'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.source       = { :git => 'https://github.com/ridi/cocoa-oauth2.git', :tag => s.version }
  s.source_files = 'Sources/RidiOAuth2/*.swift'
  s.frameworks   = 'Foundation'
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'RxSwift', '~> 4.0'
end
