# frozen_string_literal: true
Gem::Specification.new do |spec|
  spec.name          = 'pb_and_j'
  spec.version       = '0.0.1'
  spec.authors       = ['Travis Herrick']
  spec.email         = ['tthetoad@gmail.com']
  spec.summary       = 'Progress Bar and Just that'
  spec.description   = '
    An adjustable rate progress bar that does not monkey patch Ruby objects
  '.strip
  spec.homepage      = 'http://www.bitbucket.org/ToadJamb/gems_pb_and_j'
  spec.license       = 'LGPLV3'

  spec.files         = Dir['lib/**/*.rb', 'license/*']

  spec.extra_rdoc_files << 'readme.md'

  spec.add_dependency 'serving_seconds'

  spec.add_development_dependency 'rake_tasks'
  spec.add_development_dependency 'gems'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'travis-yaml'
  spec.add_development_dependency 'wwtd'
end
