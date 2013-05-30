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
