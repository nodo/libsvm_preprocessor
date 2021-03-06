require 'rspec'
require 'libsvm_preprocessor/preprocessor'

describe FeatureGenerator do

  let(:ary_of_terms) { ["a","b","c"] }
  let(:ary) { ["mar","rosso"] }

  context "with default options" do
    let(:generator) { FeatureGenerator.new }

    it "use unigrams" do
      expected = [{1=>["a"]}, {2=>["b"]}, {3=>["c"]}]
      expect(generator.features(ary_of_terms)).to eq(expected)
    end
  end

  context "using bigrams" do
    let(:generator) { FeatureGenerator.new(:mode => :bigram) }

    it "use bigrams" do
      expected = [{1=>["a"]}, {2=>["b"]}, {3=>["c"]}, {4=>["a","b"]}, {5=>["b","c"]}]
      expect(generator.features(ary_of_terms)).to eq(expected)
    end

    it "use ingnore duplicates" do
      expected = [{1=>["a"]}, {1=>["a"]}, {2=>["a","a"]}]
      expect(generator.features(["a","a"])).to eq(expected)
    end

  end

  context "using trichar" do
    let(:generator) { FeatureGenerator.new(:mode => :trichar) }

    it "use trichar" do
      expected = [{1=>["mar"]}, {2=>["ar "]}, {3=>["r r"]}, {4=> [" ro"]}, {5=>["ros"]}, {6=>["oss"]}, {7=> ["sso"]}]
      expect(generator.features(ary)).to eq(expected)
    end

    it "ignore duplicates" do
      expected = [{1=>["aaa"]}, {1=>["aaa"]},{1=>["aaa"]}]
      expect(generator.features(["aaaaa"])).to eq(expected)
    end

    it "workarounds little word" do
      expected = [{1 => ["te"]}]
      expect(generator.features(["te"])).to eq(expected)
    end

    it "workarounds little words" do
      expected = [{1 => ["te "]}, {2 => ["e n"]}, {3 => [" ne"]}]
      expect(generator.features(["te", "ne"])).to eq(expected)
    end

  end

end
