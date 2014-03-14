Gem::Specification.new do |s|
  s.name        = "atlasats"
  s.version     = "1.0.4"
  s.date        = "2014-03-11"
  s.summary     = "Atlas ATS ruby library."
  s.description = "Atlas ATS ruby library. Gives access to order placement and market data."
  s.authors     = ["Habeel Ahmed"]
  s.email       = 'habeel@atlasats.com'
  s.files       = ["lib/atlasats.rb"]
  s.homepage    = 'http://rubygems.org/gems/atlasats'
  s.license     = 'MIT'
  s.add_runtime_dependency 'eventmachine', '1.0.3'
  s.add_runtime_dependency 'httparty', '0.11.0'
  s.add_runtime_dependency 'faye', '1.0.0'
end
