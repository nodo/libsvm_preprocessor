require File.expand_path("./lib/ruby-svm-preprocessor/version", __FILE__)

Gem::Specification.new do |s|
  s.name    = %q{ruby-svm-preprocessor}
  s.version = RubySVMPreprocessor::VERSION
  s.date    = %q{2013-05-03}
  s.summary = %q{Produce libSVM format}
  s.authors = ["Andrea Nodari"]
  s.email   = "andrea.nodari91@gmail.com"
  s.files   = Dir[
                  "{lib}/**/*.rb",
                  "spec/*",
                  "LICENSE",
                  "*.md"
                 ]
  s.require_paths = ["lib"]
end
