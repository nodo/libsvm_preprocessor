require 'rspec'
require_relative '../lib/ruby-svm-preprocessor'

describe RubySVMPreprocessor do

  let(:preproc) { RubySVMPreprocessor.new }

  context "adding a text" do
    it "maps new categories" do
      preproc << ["category", "bottiglia"]
      expect(preproc.categories["category"]).to eq 0
    end
  end

  context "with default settings" do
    it "produce a new vector" do
      v = (preproc << ["category", "bottiglia"])
      expect(v).to eq([0, [{1 => 1}]])
    end

    it "takes into account frequencies" do
      v = (preproc << ["category", "bottiglia bottiglia bottiglia"])
      expect(v).to eq([0, [{1 => 3}]])
    end

    it "produce svm format" do
      v = (preproc << ["category", "bottiglia bottiglia bottiglia"])
      result = preproc.toSVM(v)
      expect(result).to eq("0  1:3")
    end

  end
end
