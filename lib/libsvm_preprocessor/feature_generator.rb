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
