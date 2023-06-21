#!/usr/bin/perl -w

=head1

Claase para anotação de genes utilizando o Software Augustus
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe
package ::SnapAnotation;

=head1

 Faz consulta no Gene Finding na url
 http://mendel.cs.rhul.ac.uk/mendel.php?topic=fgen-file

=cut

sub RunSnap
{
	$filename	= shift;
	$organismo	= shift;
	$program	= shift;
	$output	= shift;

	if(@_)
	{
		$filename 	->{filename } = $_[0];
		$organismo	->{organismo} = $_[2];
		$program  	->{program  } = $_[3];
		$output	->{output   } = $_[4];
	}

	# Análise com o programa Snap
	system "$program $organismo $filename > $output ";

	# Determina um array vazio
	@genes = ();

	open(INFILE,"<$output");
	while ($line = <INFILE>)
	{
		chomp($line);
		# Substitui todos os espaços por apenas 1 espaço
		$line =~ s/[[:blank:]]+/ /g;
		# Testa se a linha contem as strings

		if(substr($line,0,1) ne '>')
		{
			 # Limpa o Array
			@exons = ();

			# Separa a linha colocando-as em colunas
			my @exons = split(/[[:blank:]]/,$line);

			if($exons[3] eq '+')
			{
				$fita = 'Forward';
			}
			elsif($exons[3] eq '-')
			{
				$fita = 'Reverse';
			}
			# pega o numero do gene
			$gen = $exons[8];
			($contig,$gen) = split (/-/,$exons[8]);
			($lixo,$gen) = split (/snap./,$gen);
			$gen = 'g'.$gen;
			$gen =~ s/[[:blank:]]+//g;
			# Limpa o array
			@gene = ();
			# Monta um array com os dados da análise
			@gene  = ($exons[0],$fita,$exons[1],$exons[2],$gen);
			push @genes, [ @gene ];
			$contig = '';
			$lixo   = '';
		}
	}
	close(INFILE);

	# Remove os arquivos 
	system "rm $filename";
	system "rm $output";

	return @genes;

}

return 1
