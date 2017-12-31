#!/bin/bash
# processes stdin to stdout, detokenizing with nametag
function die() { echo "$@" >&2; exit 1; }
set -o pipefail  # safer pipes
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # get script directory

model="$1"
[ ! -z "$model" ] || die "usage: $0 model < input > output"
[ -e "$model" ] || die "Model not found: $model"

nametag=${nametag:-$MYDIR/nametag/src/run_ner}

[ -x "$nametag" ] || die "Can't run $nametag"

tempdir=${TEMP:-/tmp}

WORK_DIR=`mktemp -d -p "$tempdir"`
# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir in $tempdir"
  exit 1
fi
# deletes the temp directory
function cleanup {      
  rm -rf "$WORK_DIR"
}
# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT

$MYDIR/output_to_detok_input.pl \
| gzip > $WORK_DIR/for-detokenizer.gz

zcat $WORK_DIR/for-detokenizer.gz \
| $nametag \
    --input=vertical --output=vertical \
    "$model" \
| gzip > $WORK_DIR/guesses.gz \
|| die "Failed to run nametag detokenizer"

zcat $WORK_DIR/for-detokenizer.gz \
| $MYDIR/interpret_detok_guesses.pl $WORK_DIR/guesses.gz \
|| die "Failed to interpret detokenizer guesses"
