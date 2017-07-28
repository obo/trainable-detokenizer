#!/usr/bin/env perl
# loads output of nametag and ./output_to_detok_input.pl and produces the final output

use strict;

my $mayg = "MaYg";

my $decisionsf = shift;

my %drop_white;
my $inh = my_open($decisionsf);
my $nr = 0;
while (<$inh>) {
  $nr++;
  chomp;
  my ($lineno, $drop, $mayg_read) = split /\t/;
  die "$decisionsf:$nr:Bad decisions format: $_" if $drop ne "drop";
  $drop_white{$lineno} = 1 if $mayg_read eq $mayg;
}
close $inh;

$nr = 0;
my $line_ended = 1;
while (<>) {
  $nr++;
  chomp;
  if ($_ eq "") {
    # new sentence
    print "\n";
    $line_ended = 1;
    next;
  }
  $line_ended = 0;
  if ($_ eq $mayg) {
    print " " if ! $drop_white{$nr};
  } else {
    print $_;
    die "$nr:Out of sync!" if $drop_white{$nr};
  }
}
print "\n" if !$line_ended;



sub my_open {
  my $f = shift;
  if ($f eq "-") {
    binmode(STDIN, ":utf8");
    return *STDIN;
  }

  die "Not found: $f" if ! -e $f;

  my $opn;
  my $hdl;
  my $ft = `file '$f'`;
  # file might not recognize some files!
  if ($f =~ /\.gz$/ || $ft =~ /gzip compressed data/) {
    $opn = "zcat '$f' |";
  } elsif ($f =~ /\.bz2$/ || $ft =~ /bzip2 compressed data/) {
    $opn = "bzcat '$f' |";
  } else {
    $opn = "$f";
  }
  open $hdl, $opn or die "Can't open '$opn': $!";
  binmode $hdl, ":utf8";
  return $hdl;
}
