require 'lingua/stemmer'
require 'stopwords'
require 'unicode'

class Tokenizer

  def initialize(options = {})
    @options = options
    @options[:stopword] ||= false
    @options[:stemming] ||= false
    @options[:lang]     ||= "it"
    @filter  = Stopwords::Snowball::Filter.new(@options[:lang])
    @stemmer = Lingua::Stemmer.new(language: @options[:lang])
  end

  def tokenize(string)
    result = process_text(string)
    result = remove_stopwords(result) if @options[:stopword]
    result = stem_each(result) if @options[:stemming]
    result
  end

  def process_text(string)
    string.downcase!
    string = Unicode.nfd(string)
    string.gsub!(/[^[:alpha:]]/, ' ')
    string.gsub!(/([a-z])([0-9])/, '\1 \2')
    string.gsub!(/([0-9])([a-z])/, '\1 \2')
    string.gsub!(/\s+/, ' ')
    string.strip!
    string.split(' ')
  end

  # Remove stopwords according to the selected language
  def remove_stopwords(ary)
    @filter.filter(ary)
  end

  # Stem each word according to the selected language
  def stem_each(ary)
    ary.map { |term| @stemmer.stem(term) }
  end

end
