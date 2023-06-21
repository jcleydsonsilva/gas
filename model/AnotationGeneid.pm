#!/usr/bin/perl -w

=head1

Classe Anotation - Módulo de automação de anotação de genes na web
Claase para anotação de genes utilizando o fgenesh
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe
package ::AnotationGeneid;

# Módulo utilizado para fazer a consulta on-line
use WWW::Mechanize;

=head1

 Faz consulta no Gene Finding na url
 http://mendel.cs.rhul.ac.uk/mendel.php?topic=fgen-file

=cut

sub QueryAnotation
{
	$sequence = shift;
	$filename = shift;
	$profile  = shift;

	if(@_)
	{
		$sequence{sequence} = $_[0];
		$filename{filename} = $_[1];
		$profile {profile } = $_[2];
	}

	my $mech = WWW::Mechanize->new();

	$mech->get('http://genome.crg.es/geneid.html');

	$mech->submit_form
				(
				fields => {
						'seq'    => "$sequence",
						'upfile' => "$filename",
						'profile'=> "$profile" ,
						'engines'=> 'normal'   ,
						'strands'=> 'both'     ,
						'format' => 'geneidCDS',
						}
				);
	
	print $mech->content;

}
return 1
