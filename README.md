# trainable-detokenizer
Ondrej Bojar, bojar@ufal.mff.cuni.cz

A trainable detokenizer relying on [NameTag](http://ufal.mff.cuni.cz/nametag).



## Usage:

```bash
  file=tokenized-file
  cat $file \
  | ./output_to_detok_input.pl > $file.for-detok
  cat $file.for-detok \
  | ./nametag/src/run_ner --input=vertical --output=vertical \
      detokenization-model \
     > $file.decisions
  cat $file.for-detok \
  | ./interpret_detok_guesses.pl $file.decisions \
  > detokenized-file
```

## Training (to detokenize obotokenizer):

The following will train a 3-stage recognition process, each trained for 30
iterations (these values are probably overkill). Other parameters were just
copied from NameTag manual.

```bash
  cat heldout-tests \
  | ./obotokenizer --alphanumerics-eager --urls --sgml \
  > optional-heldout-set
```

```bash
  cat original-texts \
  | ./obotokenizer --alphanumerics-eager --urls --sgml \
  | ./training/obotok_to_detok_training_data.pl \
  | ./nametag/src/train_ner generic external \
      ./training/corp.feats \
      3 50 -0.2 0.1 0.01 0.5 0 \
      optional-heldout-set \
  > detokenization-model
```


## Random Results

Some vaguely indicative numbers. They hugely depend on the tokenization scheme
of the particular language and on the type of texts, so you should not really
trust any comparison with them.

        	| Training Sents	| Test Sents	| Baseline        	| Training Acc	| Test Acc
        	| -------------:	| ----------:	| -----:          	| -----       	:| -----:
Japanese	| 115k          	| 5k        	| 73% (drop space)	| 99%         	| 95%
