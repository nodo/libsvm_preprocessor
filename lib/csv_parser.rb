require 'csv'
require_relative './ruby-svm-preprocessor'

OPTIONS_INPUT  = { col_sep: "\t", headers: false }
OUTPUT_DIR = '../output'

if ARGV.size != 2
  puts "ruby csv_parser.rb <train> <test>"
  exit 1
end

input_train, input_test = ARGV

output_train_path = "#{OUTPUT_DIR}/train.svm"
output_test_path = "#{OUTPUT_DIR}/test.svm"

processor = RubySVMPreprocessor.new

output_train = File.open(output_train_path, "w")
output_test  = File.open(output_test_path, "w")

CSV.foreach(input_train, OPTIONS_INPUT) do |row|
  vector = processor.toSVM(processor.push(row))
  output_train.puts vector
end

CSV.foreach(input_test, OPTIONS_INPUT) do |row|
  vector = (processor.push(row, false))
  output_test.puts processor.nice_string(vector)
end

output_train.close
output_test.close

