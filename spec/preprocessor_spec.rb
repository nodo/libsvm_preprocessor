require 'rspec'
require 'libsvm_preprocessor/preprocessor'

describe Preprocessor do

  describe "default settings" do
    let(:preproc) { Preprocessor.new }
    let(:p_trichar) { Preprocessor.new(mode: :trichar) }

    context "adding a text" do
      it "maps new categories" do
        preproc.push ["category", "bottiglia"]
        expect(preproc.categories["category"]).to eq 0
      end
    end

    context "with default settings" do
      it "produce a new vector" do
        v = (preproc.push ["category", "bottiglia"])
        expect(v).to eq([0, [{1 => 1}]])
      end

      it "takes into account frequencies" do
        v = (preproc.push ["category", "bottiglia bottiglia bottiglia"])
        expect(v).to eq([0, [{1 => 3}]])
      end

      it "produce svm format" do
        v = (preproc.push ["category", "bottiglia bottiglia bottiglia"])
        result = preproc.toSVM(v)
        expect(result).to eq("0  1:3")
      end
    end

    context "with trichar mode" do
      it "produce a new vector with frequencies" do
        v = (p_trichar.push ["category", "osso osso"])
        expect(v).to eq([0, [{1 => 2}, {2 => 2}, {3 => 1}, {4 => 1}, {5 => 1}]])
      end
    end

    context "when I am testing" do
      it "ignore new words" do
        v = preproc.push(["category", "bottiglia"], testing: true)
        expect(v).to eq([0, []])
      end

      it "remembers the old ones" do
        preproc.push(["category", "bottiglia"], testing: false)
        v = preproc.push(["category", "bottiglia vetro"], testing: true)
        expect(v).to eq([0, [{1 => 1}]])
      end

      it "produce svm format with blank features" do
        v = preproc.push(["category", "bottiglia"], testing: true)
        result = preproc.toSVM(v)
        expect(result).to eq("0 ")
      end

    end
  end

  describe "using bigrams as feature" do
    let(:preproc) { Preprocessor.new(mode: :bigram) }

    context "adding a text" do
      it "maps new categories" do
        preproc.push ["category", "bottiglia"]
        expect(preproc.categories["category"]).to eq 0
      end
    end

    context "simple vectorization" do
      it "produce a new vector" do
        v = (preproc.push ["category", "bottiglia"])
        expect(v).to eq([0, [{1 => 1}]])
      end

      it "takes into account frequencies" do
        v = (preproc.push ["category", "bottiglia bottiglia bottiglia"])
        expect(v).to eq([0, [{1 => 3}, {2 => 2}]])
      end

      it "produce svm format" do
        v = (preproc.push ["category", "bottiglia bottiglia bottiglia"])
        result = preproc.toSVM(v)
        expect(result).to eq("0  1:3 2:2")
      end
    end

    context "when I am testing" do
      it "ignore new words" do
        v = preproc.push(["category", "bottiglia"], testing: true)
        expect(v).to eq([0, []])
      end

      it "remembers the old ones" do
        preproc.push(["category", "bottiglia"], testing: false)
        v = preproc.push(["category", "bottiglia vetro"], testing: true)
        expect(v).to eq([0, [{1 => 1}]])
      end

      it "produce svm format with blank features" do
        v = preproc.push(["category", "bottiglia"], testing: true)
        result = preproc.toSVM(v)
        expect(result).to eq("0 ")
      end

    end
  end
end
