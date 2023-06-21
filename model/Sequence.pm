#!/usr/bin/perl

# 
package ::Sequence;

# 
use IsolatedSample;
use Bio::Seq;

# 
sub setIdCodeSequence
{
  	my $idCodeSequence = shift;
  	if(@_){
  		$idCodeSequence->{idCodeSequence} = $_[0];
  	}
}

# 
sub getIdCodeSequence
{
	$idCodeSequence = shift;
	return $idCodeSequence->{codeSequence};
}

# 
sub setSequence
{
  	my $sequence = shift;
  	if(@_){
  		$sequence->{sequence} = $_[0];
  	}
}

# 
sub getSequence
{
  	my $sequence = shift;
	return $sequence->{sequence};
}

# 
sub getReverse
{
	$reverso = $sequence->{sequence};
	$reverse =~ tr/ACGT/TGCA/;
	return $reverse; 
}

# 
sub getSize
{
	$sequence = shift;
	my $seq = Bio::Seq->new( -seq => $sequence->{sequence});
	return $seq->length->seq();
}

return 1;
