#!/usr/bin/perl

package ::Manipulation;

use Bio::Seq;

# Calcula o tamanho da sequência
sub CalculateSize
{
	my $sequence = shift;

	if(@_)
	{
		my $sequence->{sequence} = $_[0];
	}
	my $seq = Bio::Seq->new( -seq => $sequence);

	# retorna o tamanho
	return $seq->length->seq();
}

# Faz o reverso complementar da sequência
sub Revcom
{
	my $sequence = shift;
	if(@_)
	{
		my $sequence->{sequence} = $_[0];
	}
	my $seq = Bio::Seq->new(-seq => $sequence);

	# retorna o  complementar reverso
	return $seq->revcom->seq();
}

# Traduz a sequência de nucleotídeos em aminoácidos
sub Translate
{
	my $sequence = shift;

	if(@_)
	{
		my @sequence->{sequence} = $_[0];
	}

	my $seq = Bio::Seq->new( -seq => $sequence);

	# Faz a tradução da sequência de DNA para Aninoácidos
	return $seq->translate->seq();
}

return 1;
