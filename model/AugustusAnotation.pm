#!/usr/bin/perl -w

=head1

Claase para anotação de genes utilizando o Software Augustus
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe
package ::AugustusAnotation;

=head1

 Faz consulta no Gene Finding na url
 http://mendel.cs.rhul.ac.uk/mendel.php?topic=fgen-file

=cut

sub RunAugustus
{
	$filename	= shift;
	$modelo	= shift;
	$organismo	= shift;
	$program	= shift;
	$output	= shift;
	$config	= shift;

	if(@_)
	{
		$filename 	->{filename } = $_[0];
		$modelo	->{modelo	} = $_[1];
		$organismo	->{organismo} = $_[2];
		$program  	->{program  } = $_[3];
		$output	->{output   } = $_[4];
		$config	->{config	} = $_[5];
	}

	# Determina um array vazio
	@genes = ();
	
	# Análise com o programa
	system "$program --genemodel=$modelo --species=$organismo --AUGUSTUS_CONFIG_PATH=$config $filename > $output ";

	open(INFILE,"<$output");
	while ($line = <INFILE>)
	{
		chomp($line);
		# Substitui todos os espaços por apenas 1 espaço
		$line =~ s/[[:blank:]]+/ /g;
		# Testa se a linha contem as o carcter > no inicio 
		if( $line =~ /CDS/)
		{
			 # Limpa o Array
			@exons = ();

			# Separa a linha colocando-as em colunas
			my @exons = split(/[[:blank:]]/,$line);

			if($exons[6] eq '+')
			{
				$fita = 'Forward';
			}
			elsif($exons[6] eq '-')
			{
				$fita = 'Reverse';
			}
			
			$gen = $exons[11];
			$gen =~ s/"/ /g;
			$gen =~ s/;/ /g;
			$gen =~ s/^[ ]/ /g;
			# Limpa o array
			@gene = ();

			# Monta um array com os dados da análise
			@gene = ($exons[2],$fita,$exons[3],$exons[4],$gen);
			push @genes, [@gene];
		}
	}
	close(INFILE);
	# Remove os arquivos 
	system "rm $filename";
	system "rm $output";
	
	return @genes;

}

return 1
