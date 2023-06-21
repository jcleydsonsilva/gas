#!/usr/bin/perl -w

=head1

Classe Anotation - Módulo de automação de anotação de genes na web
Claase para anotação de genes utilizando o fgenesh
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe

package ::FgeneshAnotation;

# Módulo utilizado para fazer a consulta on-line
use WWW::Mechanize;

=head1

 Faz consulta no Gene Finding na url
 http://mendel.cs.rhul.ac.uk/mendel.php?topic=fgen-file

=cut

sub RunFgenesh
{
	my $organismo= shift;
	my $filename = shift;
	my $output	 = shift;

	if(@_)
	{
		$organismo->{organismo 	} = $_[0];
		$filename ->{filename	} = $_[1];
		$output   ->{output	} = $_[2];
	}

	#my $mech = WWW::Mechanize->new();
	my $mech = WWW::Mechanize->new( agent => 'Perl of Love' );

      #$mech->agent_alias( 'Per Love' );
	$mech->get('http://mendel.cs.rhul.ac.uk/mendel.php?topic=fgen-file');

	$mech->submit_form
				(
				form_number => 1,
				fields => {
						file        => $filename ,
						program_name=> $organismo,
						org         => 'fgenesh' ,
						}
				);

	$result = $mech->content();
	
	open (OUT, ">>$output");
		print OUT $result;
	close(OUT);
	
	exit;

}
return 1
