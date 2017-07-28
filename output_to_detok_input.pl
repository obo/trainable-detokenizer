#!/usr/bin/env perl
# converts output of:
#   s.optimizeTags
# into the form suitable for nametag
#
# The output form delimits sentences with a blank line and interleaves tokens
# with <MaYg/>

use strict;

my $mayg = "MaYg";

my $nr = 0;
while (<>) {
  $nr++;
  chomp;
  my @toks = split /(<[^<>]+>|\s+|[^<>\s]+)/;
  my $now_emit_token = 1;
  foreach my $tok (@toks) {
    next if $tok eq "";
    if ($tok =~ /^\s+$/) {
      # whitespace, this may get dropped
      print $mayg, "\n";
      $now_emit_token = 1;
    } elsif ($tok =~ /^<g /) {
      # some glue, assume whitespace (gets preserved)
      print $tok, "\n";
      $now_emit_token = 1;
    } elsif ($tok =~ /^</) {
      # SGML tag -- don't prefix with whitespace
      print $tok, "\n";
      $now_emit_token = 1; # and don't require space afterwards
    } else {
      # regular token
      print $mayg, "\n" if !$now_emit_token;
      print $tok, "\n";
      $now_emit_token = 0;
    }
  }
  print "\n"; # sents delimited by blank lines
}
