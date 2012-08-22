Gem::Specification.new do |gem|
  gem.name = "config-parser"
  gem.summary = %Q{Parsing an options.yml file into a Hash with convenience.}
  gem.homepage = "https://github.com/SUSE/rubygem_config-parser"
  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ['lib']
  gem.version = '0.1'
end


