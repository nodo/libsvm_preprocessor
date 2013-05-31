$LOAD_PATH.unshift 'lib'
require "libsvm_preprocessor/version"

Gem::Specification.new do |s|
  s.name              = "libsvm_preprocessor"
  s.version           = LibsvmPreprocessor::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "It's a text preprocessor that generate a libsvm input file"
  s.homepage          = "http://github.com/nodo/libsvm_preprocessor"
  s.email             = "andrea.nodari91@gmail.com"
  s.authors           = [ "Andrea Nodari" ]
  s.license           = 'MIT'
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("spec/**/*")

  s.add_dependency('stopwords-filter', '~> 0.2.1')
  s.add_dependency('ruby-stemmer',     '~> 0.9.3')

  s.executables       = %w( libsvm_pp )
  s.description       = <<desc
    It's a text preprocessor that generate a libsvm input file
desc
end
