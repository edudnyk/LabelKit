Pod::Spec.new do |s|
  s.name = 'LabelKit'
  s.version = '2.0.0'
  s.license = 'Simplified BSD License'
  s.summary = 'An smart and animatable UILabel with tools for advanced text layouts, written in Swift'
  s.homepage = 'https://github.com/edudnyk/LabelKit'
  s.authors = { 'Eugene Dudnyk' => 'edudnyk@gmail.com' }
  s.source = { :git => 'https://github.com/edudnyk/LabelKit.git', :tag => s.version }
  s.ios.deployment_target = '12.0'
  s.tvos.deployment_target = '12.0'
  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5.0'
end
