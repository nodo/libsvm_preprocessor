require 'libsvm_preprocessor/tokenizer'
require 'libsvm_preprocessor/token_map'
require 'libsvm_preprocessor/feature_generator'
require 'libsvm_preprocessor/global'

class Preprocessor
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
    if options[:numeric_type]
      new_options = override_options(options)
      @options = new_options.merge(output: options[:output])
    else
      @options = options
    end

    @tokenizer  = Tokenizer.new(@options)
    @generator  = FeatureGenerator.new(@options)

    @non_zero_features = {}
    @non_zero_features[:testing]  = 0
    @non_zero_features[:training] = 0

    @instances  = {}
    @instances[:testing]  = []
    @instances[:training] = []

    @categories = {}
    @current_category_id = -1
  end

  def push(data, testing: false)
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

  def toSVM(vector)
    # the following line is made to have clean diff with libshorttext
    return "#{vector.first} " if vector.last.empty?
    features = vector.last
      .map {|h| "#{h.keys.first}:#{h[h.keys.first]}"}.join(" ")
    "#{vector.first}  #{features}"
  end

  # This method is only meant to stringify the vector in very same
  # format of libsvm (in this way diff does not mess up)
  def nice_string(v)
    return v.join("  ") if v[1] != ""
    return "#{v[0]} "
  end

  def use(input_path, output_file=nil, testing: false)
    puts "using #{@options}"
    if output_file
      output_file = File.open(output_file, "w")
      CSV.foreach(input_path, ::LibsvmPreprocessor::CSV_OPTIONS) do |row|
        output_file.puts toSVM( push(row, testing: testing) )
      end
      output_file.close
    else
      CSV.foreach(input_path, ::LibsvmPreprocessor::CSV_OPTIONS) do |row|
        puts toSVM( push(row, testing: testing) )
      end
    end
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

