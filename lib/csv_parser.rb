require 'csv'
require 'optparse'
require_relative './ruby-svm-preprocessor'

OPTIONS_INPUT  = { col_sep: "\t", headers: false }
OUTPUT_DIR = File.expand_path "~/Desktop/projects/ruby-svm-preprocessor/ruby-svm/output"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby csv_parser.rb [options] <train> <test>"

  opts.on("-m [TYPE]", "--mode [TYPE]", [:unigram, :bigram], "Select unigram (default) or bigram") do |mode|
    options[:mode] = mode
  end

  opts.on("-s", "--stemming", "Use this you want stemming") do |s|
    options[:stemming] = s
  end

  opts.on("-w", "--remove-stopwords", "Use this if you want remove stopwords") do |w|
    options[:stopword] = w
  end

  opts.on("-l", "--language", "Select your language [LANG]") do |l|
    options[:lang] = l
  end

end.parse!

if ARGV.size != 2
  puts "ruby csv_parser.rb [options] <train> <test>"
  puts "ruby csv_parser.rb --help"
  exit 1
end

input_train, input_test = ARGV

output_train_path = "#{OUTPUT_DIR}/train.svm"
output_test_path = "#{OUTPUT_DIR}/test.svm"

processor = RubySVMPreprocessor.new(options)

output_train = File.open(output_train_path, "w")
output_test  = File.open(output_test_path, "w")

CSV.foreach(input_train, OPTIONS_INPUT) do |row|
  vector = processor.toSVM(processor.push(row))
  output_train.puts vector
end

CSV.foreach(input_test, OPTIONS_INPUT) do |row|
  vector = processor.toSVM(processor.push(row, testing: true))
  output_test.puts vector
end

output_train.close
output_test.close

