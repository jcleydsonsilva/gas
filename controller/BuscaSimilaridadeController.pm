####################################################################################
# Classe RemoteBlastController
# Controla todas as requisições de análise nas bases de dados do blast vindas da 
# interface
# Autor:
# José Cleydson Ferreira da Silva - 29/10/11
#####################################################################################

#####################################################################################
# Nome a classe da controle da busca no NCBI
#####################################################################################

package BuscaSimilaridadeController;

#####################################################################################
# Bibliotecas e classes modelos utilizadas no sistema
#####################################################################################
use lib '/var/www/gsm/model/';

#use LocalBlast;
use Bio::Perl;
use RemBlast;
use Connect;


#####################################################################################
# Objeto de conexão com a base de dados
#####################################################################################
	$db = Connect::db;

#####################################################################################
# Método de controle e configuração de busca remota no NCBI
#####################################################################################
sub QueryBlast
{
	#Pega os dados enviados pela função
	my $prog	 = shift;
	my $database = shift;
	my $idisolado= shift;
	my $organismo= shift;

	# Recebe os valoes passados na função
	if(@_)
	{
		$prog		{prog     }	= $_[0];
		$database	{database }	= $_[1];
		$idisolado	{idisolado}	= $_[2];
		$organismo	{organismo}	= $_[3];
	}

	##################################################################################
	# SQL para selecionar os aminoácidos de um único isolado
	##################################################################################
	my $sql =	"SELECT idaminoacids,idtranscipty, identification,protein
			FROM aminoacids a
			INNER JOIN transcripty t On t.idtranscripty = a.idtranscipty
			INNER JOIN sequence s On t.idseq = s.idsequence
			WHERE a.stage1 <> 'Ok'
			AND s.idIsolate = '$idisolado'
			AND length(protein) >= 30
			ORDER BY a.identification";

	# Preparação e execução de da sql
	my $sth = $db->prepare($sql);
	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$genes = $sth->fetchall_arrayref();
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}

	#################################################################################
	# Faz interação com todos os transcritos, para gerar o arquivos para analisar com
	# o BLAST, inserir o resultado na base de dados
	#################################################################################
	foreach $i (@$genes)
	{

		##############################################################################
		#  Define nomes para os arquivos de entrada e saida de dados
		#  Gera um arquivo com o registro de cada sequencia depositada para ser 
		#  analisada no geneid
		##############################################################################
		# Define nomes para os arquivos de entrada e saida de dados
		$namefile	= '';
		$namefile 	= localtime(time);
		$namefile	=~ s/[[:blank:]]+/-/g;
		$namefile	.= ".txt";

		# Gera um arquivo com o registro de cada sequencia depositada para ser analisada no geneid
		$filename = "/var/www/gsm/files/in/$namefile ";
		$output   = "/var/www/gsm/files/out/$namefile";

		# Define o cabeçalho do arquivo fasta
		$indetificacao = "@$i[2]";

		##############################################################################
		# Cria o arquivo contendo os transcritos de um único gene no formato fasta
		# Inicia uma busca por similaridade no blast
		##############################################################################
		open(OUT, ">>$filename");
			print OUT "$indetificacao\n";
			print OUT "@$i[3]\n";
		close(OUT);

		# Atrasa a execução dos códigos para não ocorrer erro de leitura de arquivo
		sleep(1);

		# Classse e subrotna para buscar similaridade com o BLAST
		@homology =();
		@homology = RemBlast::QueryBlast($filename,$output,$prog,$database,$organismo);

		################################################################################
		# Insere na base de dados os hits encontrados
		# ##############################################################################
		$tam = @homology;

		if($tam > 0)
		{
			$s = 0;
			foreach $h (@homology)
			{
				if($s < 50)
				{
					if($s < 1)
					{
						# SQL para inserir os hits encontrados dos genes
						$besthit = "INSERT INTO `bestHit` (idaminoacids,accessNumber,description,score,evalue,bank)
								   VALUES ('@$i[0]','@$h[0]','@$h[1]','@$h[2]','@$h[3]','$database')";

						# Prepara a execução da SQL
						my $sth = $db->prepare($besthit);
						# Executa a SQL
						$sth->execute() or warn('Erro ao inserir melhor hit!');
					}

					# SQL para inserir os hits encontrados dos genes
					my $similarity = "INSERT INTO `similarity` (idaminoacids,nunAcesso,descrition,score,evalue,bank)
							   VALUES ('@$i[0]','@$h[0]','@$h[1]','@$h[2]','@$h[3]','$database')";

					# Prepara a execução da SQL
					my $sth = $db->prepare($similarity);

					# Executa a SQL
					$sth->execute() or warn('Erro ao inserir resultados blast!');
				}
				$s++;
			}
		}
		else
		{
			##############################################################################
			#  Define nomes para os arquivos de entrada e saida de dados
			#  Gera um arquivo com o registro de cada sequencia depositada para ser 
			#  analisada no geneid
			##############################################################################
			# Define nomes para os arquivos de entrada e saida de dados
			$namefile	= '';
			$namefile 	= localtime(time);
			$namefile	=~ s/[[:blank:]]+/-/g;
			$namefile	.= ".txt";

			# Gera um arquivo com o registro de cada sequencia depositada para ser analisada no geneid
			$filename = "/var/www/gsm/files/in/$namefile ";
			$output   = "/var/www/gsm/files/out/$namefile";

			# Define o cabeçalho do arquivo fasta
			$indetificacao = "@$i[2]";

			##############################################################################
			# Cria o arquivo contendo os transcritos de um único gene no formato fasta
			# Inicia uma busca por similaridade no blast
			##############################################################################
			open(OUT, ">>$filename");
				print OUT "$indetificacao\n";
				print OUT "@$i[3]\n";
			close(OUT);

			# Atrasa a execução dos códigos para não ocorrer erro de leitura de arquivo
			sleep(1);

			# Classse e subrotna para buscar similaridade com o BLAST
			@homology =();
			$database2 = 'nr';
			@homology = RemBlast::QueryBlast($filename,$output,$prog,$database2,$organismo);

			################################################################################
			# Insere na base de dados os hits encontrados
			# ##############################################################################
			$tam = @homology;

			if($tam > 0)
			{
				$s = 0;
				foreach $h (@homology)
				{
					if($s < 50)
					{
						if($s < 1)
						{
							# SQL para inserir os hits encontrados dos genes
							$besthit = "INSERT INTO `bestHit` (idaminoacids,accessNumber,description,score,evalue,bank)	
									   VALUES ('@$i[0]','@$h[0]','@$h[1]','@$h[2]','@$h[3]','$database2')";

							# Prepara a execução da SQL
							my $sth = $db->prepare($besthit);
							# Executa a SQL
							$sth->execute() or warn('Erro na inserção do melhor Hit!');
						}

						# SQL para inserir os hits encontrados dos genes
						my $similarity = "INSERT INTO `similarity` (idaminoacids,nunAcesso,descrition,score,evalue,bank)
								   VALUES ('@$i[0]','@$h[0]','@$h[1]','@$h[2]','@$h[3]','$database2')";

						# Prepara a execução da SQL
						my $sth = $db->prepare($similarity);

						# Executa a SQL
						$sth->execute() or warn('Erro na inserção dos Hits!');
					}
					$s++;
				}
			}
			else
			{
				# SQL para inserir os hits encontrados dos genes
				my $nohit = "INSERT INTO `noHit` (id_aminoacids,description)
						   VALUES ('@$i[1]','NOHITS')";
				# Prepara a execução da SQL
				my $sth = $db->prepare($nohit);
				# Executa a SQL
				$sth->execute() or warn('Erro na inserção do noHit!!');
			}
		}
		#########################################################
		# Atualiza o status da anotação do gene como ok
		#########################################################
		$update ="UPDATE aminoacids
			    SET stage1='Ok' WHERE idaminoacids='@$i[0]'";

		# Prepara a execução da SQL
		my $sth = $db->prepare($update);
		
		# Executa a SQL
		$sth->execute() or warn('Erro na inserção validar a busca!');
	}

	return "Processo de anotação concluído com sucesso";
}
return 1
