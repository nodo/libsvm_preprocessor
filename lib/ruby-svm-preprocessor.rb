require 'rubygems'
require 'lingua/stemmer'
require 'stopwords'
require 'unicode'

class RubySVMPreprocessor
  attr_reader :categories
  attr_reader :instances
  attr_reader :non_zero_features

  OPTIONS_MAP = {
    0  => { lang: "it", mode: :unigram, stemming: false, stopword: false },
    1  => { lang: "it", mode: :bigram, stemming: false, stopword: false },
    2  => { lang: "it", mode: :unigram, stemming: true, stopword: false },
    3  => { lang: "it", mode: :bigram, stemming: true, stopword: false },
    4  => { lang: "it", mode: :unigram, stemming: false, stopword: true },
    5  => { lang: "it", mode: :bigram, stemming: false, stopword: true },
    6  => { lang: "it", mode: :unigram, stemming: true, stopword: true },
    7  => { lang: "it", mode: :bigram, stemming: true, stopword: true },
    8  => { lang: "it", mode: :trichar, stemming: true, stopword: true },
    9  => { lang: "it", mode: :trichar, stemming: true, stopword: false },
    10 => { lang: "it", mode: :trichar, stemming: false, stopword: true },
    11 => { lang: "it", mode: :trichar, stemming: false, stopword: false },
  }

  def hash_of_ngrams
    @generator.hash_of_ngrams
  end

  def override_options(options)
    OPTIONS_MAP[options[:numeric_type]]
  end

  def self.options_map_size
    OPTIONS_MAP.size
  end

  def self.options_map(key)
    OPTIONS_MAP[key].map { |k, v| "#{k}: #{v}"}.join(" | ")
  end

  def options
    @options
  end

  def initialize(options = {})
    if options.keys.include?(:numeric_type)
      options = override_options(options)
    end
    @options = options
    @tokenizer  = Tokenizer.new(options)
    @generator  = FeatureGenerator.new(options)

    @non_zero_features = {}
    @non_zero_features[:testing]  = 0
    @non_zero_features[:training] = 0

    @instances  = {}
    @instances[:testing]  = []
    @instances[:training] = []

    @categories = {}
    @current_category_id = -1
  end

  def <<(data, testing: false)
    category, string = data
    # If it is a new category I need to associate a new id
    if !@categories[category]
      @categories[category] = next_category_id
    end
    v = vectorize(category, string, testing: testing)
    if testing
      @instances[:testing] << v
      @non_zero_features[:testing] += v.last.size
    else
      @instances[:training] << v
      @non_zero_features[:training] += v.last.size
    end
    return v
  end
  alias_method :push, :<<

  def toSVM(vector)
    # the following line is made to have clean diff with libshorttext
    return "#{vector.first} " if vector.last.empty?
    features = vector.last.map {|h| "#{h.keys.first}:#{h[h.keys.first]}"}.join(" ")
    "#{vector.first}  #{features}"
  end

  # This method is only meant to stringify the vector in very same
  # format of libsvm (in this way diff does not mess up)
  def nice_string(v)
    return v.join("  ") if v[1] != ""
    return "#{v[0]} "
  end

  private

  def vectorize(category, string, testing: false)
    tokens   = @tokenizer.tokenize(string)
    features = @generator.features(tokens, testing: testing)
    ids_with_frequency = count_frequency(features)

    [ @categories[category], ids_with_frequency ]
  end

  def count_frequency(features)
    ids = features.map { |x| x.keys.first }.sort
    result = ids.uniq.map do |id|
      { id => ids.count(id) }
    end
    result
  end

  # Give the next category id available
  def next_category_id
    @current_category_id += 1
  end

end

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

class TokenMap

  attr_reader :hash_of_ngrams

  def initialize
    @hash_of_ngrams = {}
    @current_ngram_id = 0
  end

  def token_map(ary_of_ngrams, testing: false)
    if !testing
      ary_of_ngrams.each { |ngram| @hash_of_ngrams[ngram] ||= next_ngram_id }
      ary_of_ngrams.map { |ngram| { @hash_of_ngrams[ngram] => ngram } }
    else
      ary_of_ngrams.map do |ngram|
        { @hash_of_ngrams[ngram] => ngram }
      end.select do |hash|
        hash.keys.first
      end
    end

  end

  private
  # Give the next term id available
  def next_ngram_id
    @current_ngram_id += 1
  end

end

class FeatureGenerator

  def hash_of_ngrams
    @token_map.hash_of_ngrams
  end

  def initialize(options = {})
    @token_map = TokenMap.new
    @options = options
    @options[:mode] ||= :unigram
  end

  def features(ary_of_terms, testing: false)
    if @options[:mode] == :unigram
      @token_map.token_map(unigrams(ary_of_terms), testing: testing)
    elsif @options[:mode] == :bigram
      @token_map.token_map(unigrams(ary_of_terms) +
                           bigrams(ary_of_terms),
                           testing: testing)
    elsif @options[:mode] == :trichar
      @token_map.token_map trichar(ary_of_terms)
    end
  end

  def trichar(ary_of_terms)
    string = ary_of_terms.join(" ")
    if string.size < 3
      return [ [string] ]
    end
    string1 = string[0...-2].split(//)
    string2 = string[1...-1].split(//)
    string3 = string[2..-1].split(//)
    string1.zip(string2).zip(string3).map do |x|
      [x.flatten.join]
    end
  end

  def unigrams(ary_of_term)
    ary_of_term.map { |term| [term] }
  end

  def bigrams(ary)
    ary[0...-1].zip(ary[1..-1])
  end
end

