require 'rspec'
require_relative './ruby-svm-preprocessor'

describe Tokenizer do
  let(:tokenizer) { Tokenizer.new }

  context "tokenizer with default settings" do
    it "tokenize a single word" do
      tokens = tokenizer.tokenize("bottiglia")
      expect(tokens).to eq(["bottiglia"])
    end

    it "tokenize multiple words" do
      tokens = tokenizer.tokenize("bottiglia")
      expect(tokens).to eq(["bottiglia"])
    end
  end

  context "tokenizer with stopword removal" do
    let(:tokenizer) { Tokenizer.new(stopword: true) }

    it "tokenize removing stopwords" do
      tokens = tokenizer.tokenize("bottiglia di vetro")
      expect(tokens).to eq(["bottiglia", "vetro"])
    end
  end

  context "tokenizer with stopword removal" do
    let(:tokenizer) { Tokenizer.new(stemming: true) }

    it "tokenize stemming each word" do
      tokens = tokenizer.tokenize("bottiglia di vetro")
      expect(tokens).to eq(["bottigl", "di", "vetr"])
    end
  end
end
