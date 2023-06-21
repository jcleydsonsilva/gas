#!/usr/bin/perl -w

=head1

Classe Anotation - Módulo de automação de anotação de genes na web
Claase para anotação de genes utilizando o fgenesh
José Cleydson ferreira da SIlva
20/09/2011

=cut

# Nome do pacote, refere-se ao nome da classe

package ::GenScanAnotation;

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
	$organismo= shift;
	$output   = shift;

	if(@_)
	{
		$sequence ->{sequence}  = $_[0];
		$filename ->{filename}  = $_[1]; 
		$organismo->{organismo} = $_[2]; 
		$output   ->{output}    = $_[3]; 
	}

	my $mech = WWW::Mechanize->new();

	$mech->get('http://genes.mit.edu/GENSCAN.html');

	$mech->submit_form
				(
				fields => {
						'-s'	 => "$sequence  ",
						'file' => "$filename  ",
						'-o'   => "$organismo ",
						'-p'   => "$output    ",
						}
				);
	print $mech->content;
}

sub RunGenScan
{
	$filename 	= shift;
	$organismo	= shift;
	$program  	= shift;
	$output	= shift;

	if(@_)
	{
		$filename 	->{filename } = $_[0]; 
		$organismo	->{organismo} = $_[1];
		$program  	->{program  } = $_[2];
		$output	->{output   } = $_[3];
	}

	# Análise com o programa
	system "$program $organismo $filename > $output ";

	open(INFILE,"<$output");
	while ($line = <INFILE>)
	{
		chomp($line);

		# Substitui todos os espaços por apenas 1 espaço
		$line =~ s/[[:blank:]]+/ /g;
		#Remove o espaço em branco do inicio da linha
		$line =~ s/^[[:blank:]]+//g;
		# Testa se a linha contem as strings 
		if($line =~ /[0-9][.][0-9]*[[:blank:]].+[[:blank:]][+-]/ )
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

			# Limpa o array
			@gene = ();
			# Monta um array com os dados da análise
			@gene 	 = ($key,$fita,$initial,$final);
			$genes{$key} = [ @gene ];
			print $line."<br>";
		}
	}
	close(INFILE);
	# Remove os arquivos criados
	system "rm $filename";
	system "rm $output"  ;

}

return 1
