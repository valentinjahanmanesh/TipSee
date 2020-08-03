#
# Be sure to run `pod lib lint TipSee.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.version          = '1.6.4'
  s.name             = 'TipSee'
  s.module_name      = 'TipSee'
  s.summary          = 'A lightweight, highly customizable tip / hint library for Swift'
  s.swift_version = '5.0'

  s.description      = <<-DESC
  TipSee is a lightweight and highly customizable library that helps you to show beautiful tips and hints.
                       DESC

  s.homepage         = 'https://github.com/farshadjahanmanesh/TipSee'
  s.screenshots     = 'https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC_1.png','https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC_2.png', 'https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC_3.png', 'https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC_4.png', 'https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC_5.png','https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC_6.png','https://github.com/farshadjahanmanesh/tipC/raw/master/Example/images/TipC.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'farshadjahanmanesh' => 'farshadjahanmanesh@gmail.com' }
  s.source           = { :git => 'https://github.com/farshadjahanmanesh/TipSee', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/<farshadjahanmanesh>'
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'UIKit'
end
