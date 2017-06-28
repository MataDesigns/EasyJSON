#
# Be sure to run `pod lib lint EasyJSON.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyJSON'
  s.version          = '0.1.0'
  s.summary          = 'A simple and fast way to turn JSON dictionary or string into a Swift Object.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A simple way for turn JSON dictionaries into Swift Object.
All that you have to do is create a class who's subclass is JSONModel, then call fill(withJson:) to fill the properties of the object and
toJson() to turn the object back into JSON.
                       DESC

  s.homepage         = 'https://github.com/NicholasMata/EasyJSON'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nicholas Mata' => 'NicholasMata94@gmail.com' }
  s.source           = { :git => 'https://github.com/NicholasMata/EasyJSON.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'EasyJSON/**/*'

  s.frameworks =  'Foundation', 'UIKit'
end