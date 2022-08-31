#
# Be sure to run `pod lib lint Glory.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Glory'
  s.version          = '1.0.9'
  s.summary          = 'Framework for Glory cash recycler.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = "https://zelty.fr"
  s.license      = "MIT"
  s.author           = { 'John Kricorian' => 'john@zelty.fr' }
  s.source       = { :git => "git@bitbucket.org:zelty/glorysdk.git", :tag => "v#{s.version}" }
  s.source_files     = "GloryFramework/GloryFramework/**/*.{h,m,swift}"

  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.libraries = 'xml2'
  
end
