#
# Be sure to run `pod lib lint TaskRunner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TaskRunner'
  s.version          = '1.0.0.1'
  s.summary          = 'A concurrent/series task runner for swift projects'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#   s.description      = <<-DESC
# A concurrent/series task runner for swift projects
#                        DESC

  s.homepage         = 'https://github.com/zafersevik/TaskRunner'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zafer Sevik' => 'zafersevik@gmail.com' }
  s.source           = { :git => 'https://github.com/zafersevik/TaskRunner.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/zafersevik'

  s.ios.deployment_target = '9.3'
  s.requires_arc = true

  s.source_files = 'TaskRunner/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TaskRunner' => ['TaskRunner/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
