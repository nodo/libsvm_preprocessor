require 'rspec'
require 'libsvm_preprocessor/preprocessor'

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

  context "it remembers old ids also with other trichars" do
    it "maps new tokens" do
      token_map.token_map([["abc"],["bc "],["c a"],[" ab"],["abc"]])
      ngrams = token_map.token_map([["abc"],["c a"],["bot"]])
      expected = [{1 => ["abc"]}, {3 => ["c a"]}, {5 => ["bot"]}]
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

  context "if I am creating a test file" do
    it "does not consider new terms" do
      token_map.token_map([["bottiglia"],["di"],["plastica"]])
      ngrams = token_map.token_map([["polenta"],["valsugana"]], testing: true)

      expected = []
      expect(ngrams).to eq(expected)
    end

    it "does not consider new terms but remembers the old ones" do
      token_map.token_map([["bottiglia"],["di"],["plastica"]])
      ngrams = token_map.token_map([["tappo"],["plastica"]], testing: true)

      expected = [{3 => ["plastica"]}]
      expect(ngrams).to eq(expected)
    end

  end

end
