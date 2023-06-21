#!/usr/bin/perl

=head1
	Classe para controlar o Pipeline para busca de Genes em sequencias de DNA
	Esta classe tem como função utilizar classes para anotação de genes e inserir
	o resultado em uma base de dados.
	Autor: José Cleydson ferreira da Silva
	
	Universidade Federal de Viçosa / Faculdade Viçosa
	Departamento de Fitopatologia
	Laboratório de Biologia de população de Fitopatógenos
	Data: 28/09/2011
	- Alterações:
			- Alteração 04/10/2011: 
			* Modo de inserção modigicado devido a redundância de registros
	
=cut

package ::PipelineGeneFindController;

=head2
	Módulos do sistema que estão sendo usados
=cut

use lib '/var/www/gsm/model/';
use Connect;
use Switch;
use GeneidAnotation;
use AugustusAnotation;
use SnapAnotation;
use GlimmerHMMAnotation;
use FgeneshAnotation;
use Manipulation;
use Bio::Seq;


##############################################################################
# 0 - Bloco para instâncias de objetos utilizados
##############################################################################
my $db = Connect::db;

##############################################################################
# 1 - Método para busca de genes preditos nas sequencias que serão seleciondas
##############################################################################

sub RunGeneFind
{
	my $idIsolate = shift;
	my $program   = shift;

	if(@_)
	{
		$idIsolate{idIsolate} = $_[0];
		$program  {program  } = $_[1];
	}
	##############################################################################
	# 2 - Seleciona o id, o identificador e a sequencia de DNA
	##############################################################################
	my $sql = 	"SELECT idsequence,seqIdenticator,sequence 
			 FROM sequence
			 WHERE idIsolate=$idIsolate
			 ORDER BY seqIdenticator";
			 
	#Prepara a busca
	my $sth = $db->prepare($sql);

	# Buscará todas as sequências que estão cadastradas no banco de dados
	$sth->execute(); # Executa a sql
	$dados = $sth->fetchall_arrayref();

	##############################################################################
	# 3 - Fará uma iteração para gerar cada arquivo para ser submetido na análise
	# com o geneid
	##############################################################################
	foreach $i (@$dados)
	{
		$file = localtime();
		$file =~ s/[[:blank:]]+/-/g;
		$file.= ".txt";
		# Gera um arquivo com o registro de cada sequencia depositada para ser analisada no geneid
		$filename = "/var/www/gsm/files/in/$file";

		# Cria o arquivo
		open (OUT, ">>$filename");
			print OUT "@$i[1]\n";
			print OUT "@$i[2]\n";
		close(OUT);

		# Determina um array vazio
		@exons = ();

		# Gera o arquivo de saída com a data, para não ocorrer escrita e leitura em um mesmo arquivo
		$saida = localtime();
		$saida =~ s/[[:blank:]]+/-/g;
		$saida.= ".txt";
		$output= "/var/www/gsm/files/out/$saida";

		##############################################################################
		# 4 - Verifica qual programa é desejado para fazer a analise (GenScan,Fgenesh,
		# Geneid,Augustus)
		##############################################################################
		if($program eq 'Geneid')
		{
			# Faz a análise com o geneid, passa o arquivo de análise, parametro,
			@exons = GeneidAnotation::RunGeneid($filename);
		}
		elsif($program eq 'GenScan')
		{
			#Parâmetro de comparação para o GenScan
			$organismo 	= "/var/www/gsm/core/genscan/HumanIso.smat";
			$program 	= "/var/www/gsm/core/genscan/genscan";

			# Faz a análise com o geneid, passa o arquivo de análise, parametro,
			@exons = GenScanAnotation::RunGenScan($filename,$organismo,$program,$output);
		}
		elsif($program eq 'Augustus')
		{
			#Parâmetro de configuração de análise do software Augustus
			my $organismo= 'neurospora_crassa';
			my $modelo	 = 'complete';
			my $programa = "/var/www/gsm/core/augustus/bin/augustus";
			my $config	 = "/var/www/gsm/core/augustus/config";

			# Faz a análise com o Augustus, passa o arquivo de análise, parâmetro,
			@exons = AugustusAnotation::RunAugustus($filename,$modelo,$organismo,$programa,$output,$config);
		}
		elsif($program eq 'SNAP')
		{
			# Define a configuração do SNAP
			my $organismo= "/var/www/gsm/core/SNAP/HMM/A.gambiae.hmm ";
			my $programa = "/var/www/gsm/core/SNAP/snap";

			# Faz analise com dosftware SNAP
			@exons = SnapAnotation::RunSnap($filename,$organismo,$programa,$output);
		}
		elsif($program eq 'GlimmerHMM')
		{
			# Define a configuração do GlimmerHMM
			my $organismo= "/var/www/gsm/core/GlimmerHMM/trained_dir/train_crypto/";
			my $programa = "/var/www/gsm/core/GlimmerHMM/bin/glimmerhmm";

			# Faz analise com dosftware GlimmerHMM
			@exons = GlimmerHMMAnotation::RunGlimmerHMM($filename,$organismo,$programa,$output);
		}

		# Passa a id da sequencia para uma scalar
		$idsequence= @$i[0];

		##############################################################################
		# 5 - Insere todas as regiões preditas na base de dados
		##############################################################################
		foreach $e (@exons)
		{
			# Monta a sql para inserir os dados na tabela gene
			my $sql = " INSERT INTO `gene`(idisolatedSample,idseq,program,region,chain,start,stop,numGene)
					VALUES('$idIsolate','$idsequence','$program','@$e[0]','@$e[1]','@$e[2]','@$e[3]','@$e[4]')";

			# Prepara a execução da sql
			my $sth = $db->prepare($sql);

			# Executa a sql
			$sth->execute or print 'Erro ao inserir anotação!';
			
		}
		##############################################################################
		# 6 - Remove registros em branco caso algum programa, ou erro de semático de
		# código permita que um valor branco seja adicionado ao array de dados
		##############################################################################
		my $delete = "DELETE FROM gene 
			WHERE start='' or stop=''";
		#Prepara a busca
		my $sth = $db->prepare($delete);
		# Buscará todas as sequências que estão cadastradas no banco de dados
		$sth->execute(); # Executa a sql

		##############################################################################
		# 7 - SQL para filtas o numero de genes contidos na sequencia de DNA
		##############################################################################
		my $sqlgene ="SELECT DISTINCT numGene
				  FROM gene
				  WHERE idseq='$idsequence'
				  AND program='$program'";

		# Prepara a execução da SQL
		my $sth = $db->prepare($sqlgene);
		if($sth->execute())
		{
			# Armazena em um array de array todos os genes da sequencia
			$genes = $sth->fetchall_arrayref();
		}
		else
		{
			return 'Não foi possível selecionar os genes!';
		}
		##############################################################################
		# 7 - Seleciona todas informações necessárias para recuperar as informações de
		# a respeito da localização do gene no contig ou fragmento de DNA
		##############################################################################
		foreach $ge (@$genes)
		{
			#SQL para buscar os transcritos de um gene
			my $sql = 	"SELECT idsequence,seqIdenticator,sequence,idgene,chain,start,stop,numGene
					 FROM gene g
					 INNER JOIN sequence s On g.idseq = s.idsequence
					 WHERE s.idsequence='$idsequence'
					 AND g.numGene='@$ge[0]'
					 AND g.program='$program'";

			# Preparação e execução da SQL
			my $sth = $db->prepare($sql);
			if($sth->execute())
			{
				# Pega as posições das regiões transcritas de um unico gene
				$trascritos = $sth->fetchall_arrayref();
			}
			else
			{
				return 'Não foi possível selecionar os genes!';
			}

			# Preste atenção
			#################################################################################
			# 8 - Gera uma sequencia contendo apenas as regiões transcritas
			#  Cria váriáveis com informações a serem inseridas nas tabelas
			# Um caso de teste foi feiro para validar a possibilidade de erros neste processo
			# devido a repetição de números de acesso no processo de busca por similaridade.
			# 11/02/2012 - 1:34:30 - Madrugada de sábado
			#################################################################################
			$gene = '';
			foreach $g (@$trascritos)
			{
				# Pega a sequencia
				$sequence = @$g[2];
				# pega a indentificação da sequencia
				$idsequence = @$g[0];
				$indetificacao = "@$g[1] - @$g[7]";
				# Numero do gene no contig
				$numbergene = @$g[7];
				# Recebe a posição do gene
				$inicio = @$g[5]-1;
				$termino= @$g[6];
				$length = $termino - $inicio;
				# Exrai da sequencia de DNA o transcrito
				$gene .= substr($sequence,$inicio,$length);

				# Caso o transcrito esteja na posição reversa do DNA ele faz o reverso complementar
				if(@$g[4] eq 'Reverse')
				{
					my $seq = Bio::Seq->new( -seq => $gene);
					$gene = $seq->revcom->seq();
				}
				$chain = @$g[4];
			}
			##############################################################################
			# 9 - Insere o transcrito na base de dados
			#   - Recupera o id do transcrito
			##############################################################################
			my $transcripty = "INSERT INTO `transcripty` (idseq,program,numbergene,gene,status)
						VALUES ('$idsequence','$program','$numbergene','$gene','')";
			# Prepara a execução da SQL
			my $sth = $db->prepare($transcripty);
			# Executa a SQL
			$sth->execute();

			# Recupera o valor do id da similaridade
			my $id = "SELECT LAST_INSERT_ID() as id";
			# 2
			my $sth = $db->prepare($id);
			$sth->execute;
			@id = $sth->fetchrow_array;

			################################################################################
			# 10- Insere na base de dados a frame +1 das protínas de cada transcrito
			# ##############################################################################

			# Determina a indentificação para a sequencia de aminiácidos que estão sendo traduzidas
			$identification = "$indetificacao - $program ";

			#Traduz a frame +1 do transcrito
			my $seq = Bio::Seq->new( -seq => $gene);

			$frameforward = $seq->translate(undef, undef, 0)->seq;

			# Determina a indentificação para a sequencia de aminiácidos que estão sendo traduzidas
			$ident = '';
			$ident = "$identification-$chain";
			$ident =~ s/[[:blank:]]+/-/g;
			$ident =~ s/---/-/g;

			# SQL para iunserir o transcrito da frame +1
			my $frame1 = "INSERT INTO `aminoacids` (idtranscipty,identification,protein,stage1,stage2,stage3,stage4)
					  VALUES ('@id[0]','$ident','$frameforward','','','','')";

			# Prepara a execução da SQL
			my $sth = $db->prepare($frame1);
			# Executa a SQL
			$sth->execute();
		}
	}
	return "Anotação com o programa $program completada com suscesso!";
}

sub CheckAnotation
{
	my $idIsolate = shift;
	my $program   = shift;

	if(@_)
	{
		$idIsolate{idIsolate} = $_[0];
		$program  {program  } = $_[1];
	}

	$sql ="SELECT DISTINCT program
		 FROM gene
		 WHERE idisolatedSample='$idIsolate'";

	#Prepara a busca
	my $sth = $db->prepare($sql);

	# Buscará todas as sequências que estão cadastradas no banco de dados, 
	$sth->execute; # Executa a sql
	$dados = $sth->fetchall_arrayref;

	foreach $i (@$dados)
	{
		push @program, @$i[0];
	}

	if ($program[0] eq $program)
	{
		$verification = "Este isolado já está anotado pelo programa $program";
	}
	elsif ($program[1] eq $program)
	{
		$verification = "Este isolado já está anotado pelo programa $program";
	}
	elsif ($program[2] eq $program)
	{
		$verification = "Este isolado já está anotado pelo programa $program";
	}
	elsif ($program[3] eq $program)
	{
		$verification = "Este isolado já está anotado pelo programa $program";
	}
	elsif ($program[4] eq $program)
	{
		$verification = "Este isolado já está anotado pelo programa $program";
	}
	else
	{
		$verification = "Ok";
	}

	return $verification;
}
return 1
