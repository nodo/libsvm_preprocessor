require 'rspec'
require_relative '../lib/ruby-svm-preprocessor'

describe FeatureGenerator do

  let(:ary_of_terms) { ["a","b","c"] }

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

end
