require 'optparse'
require 'ostruct'

class CLI

  def self.parse(args)

    options = {}

    options[:mode]         = :unigram
    options[:lang]         = :it
    options[:stemming]     = false
    options[:stopwords]    = false
    options[:testing]      = false
    options[:numeric_type] = nil
    options[:output]       = nil

    opt_parser = OptionParser.new do |opts|
      opts.banner = "libsvm_pp [options] <filename>"

      opts.on("-m [TYPE]", "--mode [TYPE]", [:unigram, :bigram],
              "Select unigram (default) or bigram") do |mode|
        options[:mode] = mode
      end

      opts.on("-s", "--stemming", "Use this you want stemming") do |s|
        options[:stemming] = s
      end

      opts.on("-w", "--remove-stopwords",
              "Use this if you want remove stopwords") do |w|
        options[:stopwords] = w
      end

      opts.on("-t", "--testing",
              "Use this to use testing mode") do |t|
        options[:testing] = t
      end

      opts.on("-l [TYPE]", "--language", [:it, :en],
              "Select your language it / en") do |l|
        options[:lang] = l
      end

      opts.on("-n N", Integer, "Numeric mode") do |n|
        options[:numeric_type] = n
      end

      opts.on("-o [output]", String, "output file") do |o|
        options[:output] = o
      end
    end

    opt_parser.parse!(args)
    options
  end

end
