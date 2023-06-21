#!/usr/bin/perl -w

=head1

Classe Anotation - Módulo de automação de anotação de genes na web
Claase para anotação de genes utilizando o fgenesh
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe
package ::GeneidAnotation;

sub RunGeneid
{
	$filename = shift;

	if(@_)
	{
		$filename{filename} = $_[0];
	}

	# Determina um array vazio
	@genes = ();

	# Funcionando perfeitamente usando caminho completo dos arquivos
	#system "$program -P $param -D $filename > $output";
	system "/var/www/gsm/core/geneid/geneid -P /var/www/gsm/core/geneid/neurospora.param -D $filename > /var/www/gsm/files/out/geneid.txt";

	open(INFILE,"</var/www/gsm/files/out/geneid.txt");
	while ($line = <INFILE>)
	{
		chomp($line);

		if($line =~ /First/ or $line =~ /Internal/ or $line =~ /Terminal/ or $line =~ /Single/)
		{
			# Substitui todos os espaços por apenas 1 espaço
			$line =~ s/[[:blank:]]+/ /g;
			
			# Retira os espaços do inicio da linha
			$line =~ s/^[[:blank:]]+//g;

			# Limpa o Array
			@exons = ();

			# Separa a linha colocando-as em colunas
			my @exons = split(/[[:blank:]]/,$line);

			# Define a posição inicial e final
			my $initial= $exons[1];
			my $final  = $exons[2];

			# Define a região (First, Internal, exon, Terminal)
			my $region = $exons[0];

			# Deternima se é fita senso ou reversa
			if($exons[4] eq '+')
			{
				$fita = 'Forward';
			}
			elsif($exons[4] eq '-')
			{
				$fita = 'Reverse';
			}
			# Pega o numero do gene
			$gen = reverse $exons[14];
			($gen,$trash) = split (/_/,$gen);
			#($contig,$gen) = split (/_/,$gen);

			if($exons[14] eq '')
			{
				$gen = reverse $exons[13];
				($gen,$trash) = split (/_/,$gen);
			}
			$gen = 'g'.$gen;
			# Limpa o array
			@gene = ();
			# Monta um array com os dados da análise
			@gene	= ($region,$fita,$initial,$final,$gen);
			# Armazena os dados em um array de array
			push @genes, [@gene];
		}
	}
	close(INFILE);

	# Remove os arquivos gerados
	system "rm $filename";
	system "rm /var/www/gsm/files/out/geneid.txt";

	# Retorna um array de array
	return @genes;
}

=head1
	Faz a análise no gene id e imprime na tela
=cut

sub PrintAnotation
{
	$sequence = shift;
	$filename = shift;
	$profile  = shift;

	if(@_)
	{
		$sequence {sequence } = $_[0];
		$filename {filename } = $_[1];
		$profile  {profile  } = $_[2];
	}

	# Funcionando perfeitamente usando caminho completo dos arquivos
	system "/var/www/gsm/core/geneid/geneid -P /var/www/gsm/core/geneid/$profile -D $filename > /var/www/gsm/files/out/geneid.txt";
	$result = `cat /var/www/gsm/files/out/geneid.txt `;

	print "<pre>";
		print $result;
	print "</pre>";

	system "rm $filename";
	system "rm /var/www/gsm/files/out/geneid.txt";
}

return 1
