#!/usr/bin/perl

package ::LocalBlast;

use lib '/var/www/gsm/model/';

use Bio::SearchIO; 
use Connect;
use Switch;

# Obeject in the database 
my $db   = Connect::db;

# Path for database
$pathDatabase= '/var/www/gsm/database/';
$fileIn 	 = '/var/www/gsm/files/in/';
$fileOut     = '/var/www/gsm/files/out/';
$tools	 = '/usr/local/bioinformatics';
$ncbi		 = '/home/cleysinho/ncbi/database';
$resultblast = localtime();
$resultblast =~ s/[[:blank:]]+/-/g;
$resultblast.= ".txt";


sub setProgram
{
	my $program = shift;
	if(@_)
	{
		$program->{program} = $_[0];
	}
}

sub getProgram
{
	my $program = shift;
	return $program->{program}; 
}

sub setDatabase
{
	my $database = shift;
	if(@_)
	{
		$database->{database} = $_[0];
	}
}

sub getDatabase
{
  my $database = shift;
  	return $database->{database};
}

sub setQuery
{
	my $query = shift;
	if(@_)
	{
		$query->{query} = $query;
	}
}

sub getQuery
{
	my $query = shift;
	return $query;
}

sub setResult
{
	my $result = shift;
	if(@_)
	{
		$result->{result} = $_[0];
	}
}

sub getResult
{
	my $result = shift;
	return $result->{result};
}
# Método para buscar na base de dados local, esse método seleciona os dados contidos no
# banco de dados MYSQl e formata no formato que o programa blastn  reconhece

sub QueryBlast
{
	my ($program,$filename) = @_;

	$databaseBlast = 'muDatabase.fasta';

	if($program eq 'blastn')
	{
		# SQL para consultar todas as sequencias no banco de dados
		$sql = "SELECT seqIdenticator, sequence from sequence";
		# Prepara a SQL para a execução
		my $sth = $db->prepare($sql);
		#Executa a SQL
		if ($sth->execute())
		{	
			#Recupera os dados da SQL em um array de array(Linhas)
			$result = $sth->fetchall_arrayref();
			# Grava o resultado em um arquivo
			open (OUTFILE,">$pathDatabase$databaseBlast") || warn "ERRO";
				foreach $i (@$result)
				{
					print OUTFILE @$i[0]."\n";
					print OUTFILE @$i[1]."\n";
				}
			close(OUTFILE);

			# Formata as sequencias selecionadas na base de dados em formato especifico do NCBI
			system "/usr/local/bioinformatics/formatdb -i $pathDatabase$databaseBlast -p F -n $pathDatabase$databaseBlast";

			#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
			system "$tools/blastn -query $fileIn$filename -db $pathDatabase$databaseBlast -html > $fileOut$resultblast";

			# Redireciona para a página de resultados do blast.
			CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');
		}
	}
	else
	{
		CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/');
	}
}
# Método para busca na base de dados em regiões transcritas dos isolados cadastrados
sub QueryTranscripty
{
	my $program  = shift;
	my $filename = shift;

	if(@_)
	{
		$program{program}  = $_[0];
		$filename{filename}= $_[1];
	}

	$databaseBlast = 'muTranscrito.fasta';

	if($program eq 'blastn')
	{
		# SQL para consultar todas as sequencias no banco de dados
		$sql ="SELECT identification, gene from transcripty t 
			 INNER JOIN aminoacids a On t.idtranscripty = a.idtranscipty";

		# Prepara a SQL para a execução
		my $sth = $db->prepare($sql);
		#Executa a SQL
		if ($sth->execute())
		{
			#Recupera os dados da SQL em um array de array(Linhas)
			$result = $sth->fetchall_arrayref();
			# Grava o resultado em um arquivo
			open (OUTFILE,">$pathDatabase$databaseBlast") || warn "ERRO";
				foreach $i (@$result)
				{
					print OUTFILE @$i[0]."\n";
					print OUTFILE @$i[1]."\n";
				}
			close(OUTFILE);

			# Formata as sequencias selecionadas na base de dados em formato especifico do NCBI
			system "/usr/local/bioinformatics/formatdb -i $pathDatabase$databaseBlast -p F -n $pathDatabase$databaseBlast";

			#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
			system "$tools/blastn -query $fileIn$filename -db $pathDatabase$databaseBlast -html > $fileOut$resultblast";

			# Redireciona para a página de resultados do blast.
			CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');
		}
	}
	else
	{
		CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/');
	}
}

# Método para busca na base de dados de genes dos isolados cadastrados
sub QueryGene
{
	my $program  = shift;
	my $filename = shift;

	if(@_)
	{
		$program{program}  = $_[0];
		$filename{filename}= $_[1];
	}

	$databaseBlast = 'muGene.fasta';

	if($program eq 'blastp' or $program eq 'blastx' or $program eq 'tblastx' )
	{
		# SQL para consultar todas as sequencias no banco de dados
		$sql ="SELECT identification, protein from aminoacids";

		# Prepara a SQL para a execução
		my $sth = $db->prepare($sql);
		#Executa a SQL
		if ($sth->execute())
		{
			#Recupera os dados da SQL em um array de array(Linhas)
			$result = $sth->fetchall_arrayref();
			# Grava o resultado em um arquivo
			open (OUTFILE,">$pathDatabase$databaseBlast") || warn "ERRO";
				foreach $i (@$result)
				{
					print OUTFILE @$i[0]."\n";
					print OUTFILE @$i[1]."\n";
				}
			close(OUTFILE);

			# Formata as sequencias selecionadas na base de dados em formato especifico do NCBI
			system "/usr/local/bioinformatics/formatdb -i $pathDatabase$databaseBlast -p T -n $pathDatabase$databaseBlast";

			if($program eq 'blastp')
			{
				#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
				system "$tools/blastp -db $pathDatabase$databaseBlast -query $fileIn$filename -html > $fileOut$resultblast";
			}
			elsif($program eq 'blastx')
			{
				#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
				system "$tools/blastx -db $pathDatabase$databaseBlast -query $fileIn$filename -html > $fileOut$resultblast";
			}
			# Redireciona para a página de resultados do blast.
			CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');
		}
	}
	else
	{
		CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/');
	}

}

# Método para iniciar uma busca na base de dados do NCBI
sub BlastNCBI
{
	my ($program,$filename) = @_;

	# Executa o a pesquisa na base de dados NCBi que esta configurada de forma independente.
	system "$tools/$program -query $fileIn$filename -db $ncbi/nt -html > $fileOut$resultblast"; 

	# Redireciona para a página de resultados do blast.
	CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');
}

sub BlastMycosphaerellaceae
{

	my ($program,$filename) = @_;

	# Executa o a pesquisa na base de dados NCBi que esta configurada de forma independente.
	system "$tools/$program -query $fileIn$filename -db $ncbi/Mycosphaerellaceae -html > $fileOut$resultblast"; 

	# Redireciona para a página de resultados do blast.
	CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');

}

sub BlastNr
{
	my ($program,$filename) = @_;

	if($program eq 'blastp' or 	$program eq 'blastx' )
	{
		$databaseBlast = 'nr-aa.fasta';
		# SQL para consultar todas as sequencias no banco de dados
		$sql ="SELECT identification,nunAcesso,protein FROM aminoacids a INNER JOIN noredundancy r On a.idaminoacids=r.id_aminoacids INNER JOIN similarity s On r.id_simlarity = s.idsimilarity";

		# Prepara a SQL para a execução
		my $sth = $db->prepare($sql);
		#Executa a SQL
		if ($sth->execute())
		{
			#Recupera os dados da SQL em um array de array(Linhas)
			$result = $sth->fetchall_arrayref();
			# Grava o resultado em um arquivo
			open (OUTFILE,">$pathDatabase$databaseBlast") || warn "ERRO";
				foreach $i (@$result)
				{
					print OUTFILE "@$i[0]@$i[1]\n";
					print OUTFILE @$i[2]."\n";
				}
			close(OUTFILE);

			# Formata as sequencias selecionadas na base de dados em formato especifico do NCBI
			system "/usr/local/bioinformatics/formatdb -i $pathDatabase$databaseBlast -p T -n $pathDatabase$databaseBlast";

			if($program eq 'blastp')
			{
				#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
				system "$tools/blastp -db $pathDatabase$databaseBlast -query $fileIn$filename -html > $fileOut$resultblast";
			}
			elsif($program eq 'blastx')
			{
				#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
				system "$tools/blastx -db $pathDatabase$databaseBlast -query $fileIn$filename -html > $fileOut$resultblast";
			}
			# Redireciona para a página de resultados do blast.
			CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');
		}
	}
	elsif($program eq 'blastn')
	{
		$databaseBlast = 'nr-nt.fasta';
		# SQL para consultar todas as sequencias no banco de dados
		$sql =" SELECT identification,gene FROM transcripty t INNER JOIN noredundancy r On t.idtranscripty=r.id_transcripty INNER JOIN aminoacids a On r.id_aminoacids = a.idaminoacids";

		# Prepara a SQL para a execução
		my $sth = $db->prepare($sql);
		#Executa a SQL
		if ($sth->execute())
		{
			#Recupera os dados da SQL em um array de array(Linhas)
			$result = $sth->fetchall_arrayref();
			# Grava o resultado em um arquivo
			open (OUTFILE,">$pathDatabase$databaseBlast") || warn "ERRO";
				foreach $i (@$result)
				{
					print OUTFILE "@$i[0]\n";
					print OUTFILE "@$i[1]\n";
				}
			close(OUTFILE);

			if($program eq 'blastn')
			{
			# Formata as sequencias selecionadas na base de dados em formato especifico do NCBI
			system "/usr/local/bioinformatics/formatdb -i $pathDatabase$databaseBlast -p F -n $pathDatabase$databaseBlast";

			#Faz a pesquisa por sequencias na sililares na base de dados que esta sendo formatada.
			system "$tools/blastn -query $fileIn$filename -db $pathDatabase$databaseBlast -html > $fileOut$resultblast";
			}

			# Redireciona para a página de resultados do blast.
			CGI::redirect(-URL=>'http://200.235.177.179/gsm/view/public/resultBlast.pl');
		}
	}
}


# Método para recuperar o resultado do blast
sub BlastResult
{
	# Lê o arquivo com resultado do blast, tal resultado é armazenado em formato html.
	my $result = `cat $fileOut$resultblast`;
	
	# Remove os arquivos enviados após a leitura do resultado. A não remoção destes/desses arquivos
	# podem gerar um acumulo de arquivos em disco e ocupar um espaço desnecessariamente.
	system "rm $fileIn*";
	#system "rm $fileOut*";
	system "rm $pathDatabase*";

	# Retorna o resultado do blast
	return $result;
}
return 1;
