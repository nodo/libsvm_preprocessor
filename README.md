# Libsvm_preprocessor

This project is a simple ruby gem that provide a way to transform a text into sparse features vector using libsvm/liblinear format (<http://www.csie.ntu.edu.tw/~cjlin/libsvm>).

Since this tool is thought to be used with short-text it provides only binary representations of tokens.

## Usage
```
	% libsvm_pp --help
	libsvm_pp [options] <filename>
  	 -m, --mode [TYPE]                Select unigram (default)/bigram/trigrams
     -s, --stemming                   Use this you want stemming
     -w, --remove-stopwords           Use this if you want remove stopwords
     -t, --testing                    Use this to use testing mode
     -l, --language [TYPE]            Select your language it / en
     -n N                             Numeric type
	 -o [output]                      output file
```

It is possible to use the library following these steps:

```
require "libsvm_preprocessor/preprocesso"

[…]

preprocessor = Preprocessor.new(numeric_type: i)
preprocessor.use("TRAIN.csv", "TRAIN.svm")
preprocessor.use("TEST.csv", "TEST.svm", testing: true)
```

In this case TRAIN.svm will contain your training set and TEST.svm will contain the testing set.


This project is far to be complete, as soon as possible I will provide a better documentation.