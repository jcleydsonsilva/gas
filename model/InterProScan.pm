package InterProScan;

# Name: Classe InterProScan

=head1
	1 - BlastProDom:

	The ProDom protein domain database consists of an automatic compilation of homologous domains.

	2 - HMMTigr:

	3 - SignalPHMM:
	4 - FPrintScan:
	5 - ProfileScan:
	6 - TMHMM:
	7 - HMMPIR:
	8 - HAMAP:
	9 -  HMMPanther:
	10 - HMMPfam:
	11 - PatternScan:
	12 - HMMSmart:

=cut

use Connect;
use WWW::Mechanize;

##########################################
# Objeto de conexão com a base de dados
##########################################
	$db = Connect::db;

sub SetFamily
{
	my $family = shift;
	if(@_)
	{
		$family{family} = $_[0];
	}
}

sub SetGo
{
	my $go = shift;
	if(@_)
	{
		$go{go} = $_[0];
	}
}

sub GetFamily
{
	my $family = shift;
	return $family;
}

sub GetGo
{
	my $go = shift;
	return $go;
}

sub RunInterProScan
{
	my $sequence = shift;
	my $output	 = shift;

	if(@_)
	{
		$sequence{sequence} = $_[0];
		$output  {output  } = $_[1];
	}

	my $mech = WWW::Mechanize->new();

	$mech->get('http://www.ebi.ac.uk/Tools/pfa/iprscan/');

	$mech->submit_form
				(
				fields => {
						'sequence'=> "$sequence", 
						'appl'    => 'blastprodom',
						'appl'    => 'fprintscan' ,
						'appl'    => 'hmmpir'	,
						'appl'    => 'hmmpfam'	,
						'appl'    => 'hmmsmart'	,
						'appl'    => 'hmmtigr'	,
						'appl'    => 'profilescan',
						'appl'    => 'hamap'	,
						'appl'    => 'patternscan',
						'appl'    => 'signalp'	,
						'appl'    => 'tmhmm'	,
						'appl'    => 'hmmpanther' ,
						}
				);


	$linkoriginal = 'http://www.ebi.ac.uk/Tools/services/web/';
	$adicional = '&analysis=output';
	@links     = $mech->find_all_links();

	while(index($mech->content(format => 'text'), "InterProScan Results") == -1)
	{
		if($mech->get($linkoriginal.$links[0]->url.$adicional))
		{};
	}

	$link = 'http://www.ebi.ac.uk';
	@links     = $mech->find_all_links();

	if($mech->get($link.$links[15]->url))
	{
		open (OUTFILE,">$output") || warn "ERRO";
			print OUTFILE $mech->content;
		close(OUTFILE);
		return 'Ok';
	}
	else
	{
		return 'No';
	}
}

sub ParserInterProScan
{
	my $output 		= shift;
	my $idaminoacids	= shift;

	if(@_)
	{
		$output{outout} 		   = $_[0];
		$idaminoacids{idaminoacids}= $_[1];
	}
	# Determina o array que retornará os dados como vazio
	@interpro = ();
	@goall    = ();

	# Abre o arquivo para leitura dos dados
	open(INFILE,"<$output");

		while($line = <INFILE>)
		{
			# limpam os arrays
			@split = ();
			@go_split  = ();
			@gopartial = ();

			# Retira o espaço em branco do fim da linha
			chomp($line);

			# Corta a linha onde houver tabulação
			@split = split (/\t/,$line);

			# Retira aspas e parenteses da linha
			$go_split = $split[13];
			$go_split =~ s/\)//g;
			$go_split =~ s/"//g;

			# Quebra a linha onde houver virgula
			@go_split = split(/,/,$go_split);

			$tam = @go_split;
			$i=0;

			# Compara se o tamanho do array
			while($i <= $tam)
			{
				# limpam os arrays
				@goline   = ();
				@godesc   = ();
				@function = ();

				# Quebra a linha onde houver dois pontos
				@function = split (/:[[:blank:]]/,$go_split[$i]);

				# Quebra a linha onde houver contra barra e um inicio de parenteses
				@godesc = split (/[[:blank:]]\(/,$function[1]);

				# Retira os  espaços em brancos do inicio da linha
				$function[0] =~ s/^[ ]//g;

				# Verifica se há algum registro dentro do array que está vazio
				if($function[0] =~ /[A-Za-z]/)
				{
					@goline = ($function[0],$godesc[0],$godesc[1]);
					push @goall , [@goline];
				}
				$i++;
			}

			# Faz formaração de dados, retira do inicio da linhas as aspas
			$split[3]	=~ s/^"//g;
			$split[4]	=~ s/^"//g;
			$split[5]	=~ s/^"//g;
			$split[11]	=~ s/^"//g;
			$split[12]	=~ s/^"//g;

			# Faz formaração de dados, retira do fim da linhas as aspas
			$split[3]	=~ s/"//g;
			$split[4]	=~ s/"//g;
			$split[5]	=~ s/"//g;
			$split[11]	=~ s/"//g;
			$split[12]	=~ s/"//g;

			# Pega os valores
			if($split[3] =~ /[A-Za-z]/)
			{
				@gopartial = ($split[3],$split[4],$split[5],$split[11],$split[12]);
				# Coloca na ultima posição do array final
				push @interpro, [@gopartial];
			}
		}
	close(INFILE);

	$tmp = 'vazio';
	foreach $f (@interpro)
	{
		if($tmp ne @$f[3])
		{
			if((@$f[0] =~ /</))
			{}
			else
			{
				# Armazena o valor do interpro, para comparar posteriormente para não haver duplicação de dados
				$tmp = @$f[3];

				# Sql para inserir os dados referentes a familia de proteína
				$proteinFamily = "INSERT INTO `proteinFamily` (id_aminoacids,metodo,numacesso,descricao,numInterpro,descricaoInterpro)
						   VALUES ('$idaminoacids','@$f[0]','@$f[1]','@$f[2]','@$f[3]','@$f[4]')";

				# Prepara a execução da SQL
				my $sth = $db->prepare($proteinFamily);

				# Executa a SQL
				$sth->execute();
			}
		}
	}

	$tmp1 = 'vazio';
	foreach $g (@goall)
	{
		if($temp1 ne @$g[1])
		{
			# Sql para inserir os dados referentes a Gene ontology
			$geneOntology = "INSERT INTO `geneOntology` (id_aminoacids,functionOntology,descricao,numGo)
					   VALUES ('$idaminoacids','@$g[0]','@$g[1]','@$g[2]')";

			# Prepara a execução da SQL
			my $sth = $db->prepare($geneOntology);

			# Executa a SQL
			$sth->execute();
		}
		
	}
	# Remove o arquivo de output
	system "rm $output";
}
return 1
