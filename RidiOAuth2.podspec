Pod::Spec.new do |s|
  s.name         = 'RidiOAuth2'
  s.version      = '1.0.0-alpha.1'
  s.summary      = 'OAuth2 client library written in Swift for RIDI account authorization.'
  s.homepage     = 'https://github.com/ridi/cocoa-oauth2'
  s.authors      = { 'Ridibooks Viewer Team' => 'viewer.team@ridi.com' }
  s.license      = 'MIT'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.source       = { :git => 'https://github.com/ridi/cocoa-oauth2.git', :tag => s.version }
  s.source_files = 'RidiOAuth2/RidiOAuth2.swift'
  s.frameworks   = 'Foundation'
end