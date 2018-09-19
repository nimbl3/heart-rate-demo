# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def testing_pods
  pod 'Quick'
  pod 'Nimble'
end

target 'Heart rate demo' do
  use_frameworks!

  pod 'SwiftLint'
  pod 'SnapKit'

  target 'Heart rate demoTests' do
    inherit! :search_paths
    testing_pods
  end

  target 'Heart rate demoUITests' do
    inherit! :search_paths
    testing_pods
  end
end
