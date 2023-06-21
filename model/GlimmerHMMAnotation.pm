#!/usr/bin/perl -w

=head1

Claase para anotação de genes utilizando o Software Augustus
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe
package ::GlimmerHMMAnotation;

=head1

 Faz consulta no Gene Finding na url
 http://mendel.cs.rhul.ac.uk/mendel.php?topic=fgen-file

=cut

sub RunGlimmerHMM
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
	
	# Determina um array vazio para evitar duplicação de dados
	@genes = ();
	# Análise com o programa GlimmerHMM
	system "$program $filename $organismo  > $output ";

	open(INFILE,"<$output");
	while ($line = <INFILE>)
	{
		chomp($line);
		# Substitui todos os espaços por apenas 1 espaço
		$line =~ s/[[:blank:]]+/ /g;
		$line =~ s/^[[:blank:]]//g;
		# Testa se a linha contem as strings
		if($line =~ /^[0-9].*[[:blank:]][0-9][[:blank:]][+-]/)
		{
			 # Limpa o Array
			@exons = ();

			# Separa a linha colocando-as em colunas
			my @exons = split(/[[:blank:]]/,$line);

			if($exons[2] eq '+')
			{
				$fita = 'Forward';
			}
			elsif($exons[2] eq '-')
			{
				$fita = 'Reverse';
			}
			$gen = 'g'.$exons[0];
			# Limpa o array
			@gene = ();
			# Monta um array com os dados da análise
			@gene 	 = ($exons[3],$fita,$exons[4],$exons[5],$gen);
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
