require 'rspec'
require_relative './ruby-svm-preprocessor'

describe TokenMap do
  let(:token_map) { TokenMap.new }

  context "it maps terms in new ids" do
    it "maps new tokens" do
      ngrams = token_map.token_map([["bottiglia"],["di"],["vetro"]])
      expected = [{1 => ["bottiglia"]}, {2 => ["di"]}, {3 => ["vetro"]}]
      expect(ngrams).to eq(expected)
    end
  end

  context "it remembers old ids" do
    it "maps new tokens" do
      token_map.token_map([["bottiglia"],["di"],["vetro"]])
      ngrams = token_map.token_map([["bottiglia"],["di"],["plastica"]])
      expected = [{1 => ["bottiglia"]}, {2 => ["di"]}, {4 => ["plastica"]}]
      expect(ngrams).to eq(expected)
    end
  end

  context "it ignores duplicates" do
    it "maps new tokens" do
      ngrams = token_map.token_map([["bottiglia"],["di"],["plastica"],["plastica"]])
      expected = [{1 => ["bottiglia"]}, {2 => ["di"]}, {3 => ["plastica"]}, {3 => ["plastica"]}]
      expect(ngrams).to eq(expected)
    end
  end

end
