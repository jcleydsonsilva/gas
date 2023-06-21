#!/usr/bin/perl -w
use strict;

my $FORGE = "../Genome/1000/Forge";
my %H = (
	'A.thaliana'     => "-A 1:20 -D 1:9 -M 1:12 -xo A.thaliana $FORGE/At/all",
	'C.elegans'      => "-A 0:15 -D 2:9 -M 2:18 -xo C.elegans $FORGE/Ce/all",
	'D.melanogaster' => "-A 2:40 -D 2:15 -M 1:18 -o D.melanogster $FORGE/Dm/all",
	'O.sativa'       => "-A 0:40 -o O.sativa $FORGE/Os/all",
);

my @Generic = qw(At Ce Dm Os);
foreach my $g (@Generic) {$H{$g} = "-o $g $FORGE/$g/all"}

foreach my $name (keys %H) {
	system("hmm-assembler.pl $H{$name} > $name.hmm");
}
