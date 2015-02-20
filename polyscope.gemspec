$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "polyscope/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "polyscope"
  s.version     = Polyscope::VERSION
  s.authors     = ["Julien P.Lefebvre"]
  s.email       = ["julienplefebvre@gmail.com"]
  s.homepage    = "https://github.com/webgem-jpl/polyscope"
  s.summary     = "Polyscope is gem that make possible to create easily shape through models association and calculate difference in the different shapes."
  s.description = "TODO: Description of Polyscope."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
  s.add_dependency "rails", "~> 4.2.0"
  s.test_files = Dir["spec/**/*"]
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
end
