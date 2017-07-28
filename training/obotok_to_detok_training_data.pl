#!/usr/bin/env perl
# converts output of:
#   obotokenizer --alphanumerics-eager --urls --sgml
# into the form suitable for nametag
#
# The output form delimits sentences with a blank line and interleaves tokens
# with <MaYg/>

use strict;

$| = 1;

my $within_sentence = 0; # set to 1 after the first token within any sentence
my $now_emit_token = 1;
my $mayg = "MaYg";

my $nr = 0;
while (<>) {
  $nr++;
  chomp;
  if (/^<br\/>$/) {
    print "\n"; # new sentence => blank line
    $within_sentence = 0;
    next;
  }
  if (/^<g\/>/) {
    # <g/> at the beginning of sentences is uninteresting
    next if ! $within_sentence;
    # this line is the item we want to learn from: no space between two tokens
    die "$nr:Expected to be emitting token, but now asked to emit another $mayg"
      if $now_emit_token && $within_sentence;
    print "$mayg\tB-drop\n";
    $now_emit_token = 1;
  } elsif (/^<g /) {
    # this is any other glue, not just a single space, assume it behaves as
    # space
    die "$nr:Expected to be emitting token, but now asked to emit another glue: $_"
      if $now_emit_token && $within_sentence;
    print $_, "\tO\n";  # this glue is 'other', not to learn dropping it
    $now_emit_token = 1;
  } else {
    # this is a regular token, not glue
    $within_sentence = 1;
    # ensure token - learnable items are interleaved
    print "$mayg\tO\n" if ! $now_emit_token && $within_sentence;
    # print the actual token
    print $_, "\tO\n";
    $now_emit_token = 0;
  }
}
