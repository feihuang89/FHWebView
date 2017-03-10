#
# Be sure to run `pod lib lint FHWebView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FHWebView'
  s.version          = '0.1.0'
  s.summary          = 'iOS8以上切换WKWebView框架,轻易实现OC与JS交互,一句代码集成浏览器！'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
WKWebView下代理协议实现OC与JS交互，自定义网页加载进度条，京东、天猫、淘宝拦截跳转，并解决那些WKWebView中的坑！
                       DESC

  s.homepage         = 'https://github.com/zenghongfei/FHWebView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zenghongfei' => 'zenghongfei@picooc.com' }
  s.source           = { :git => 'https://github.com/zenghongfei/FHWebView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHWebView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FHWebView' => ['FHWebView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
