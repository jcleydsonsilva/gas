#!/usr/bin/perl

########################################################################
# Classe de controller da tela de anotação de genes
# 
# Autor: SILVA, JCF
# Data 22/11/2011
# Versão 1.0
########################################################################
package AnotacaoController;

########################################################################
# Módulos utilizados pela classe controller AnotationController
########################################################################
	use lib '/var/www/gsm/model/';
	use Connect;

########################################################################
# Objeto de conexão com a base de dados
########################################################################
	$db = Connect::db;

########################################################################
# Método para buscar o melhor Hit de cada gene
########################################################################
sub BestHits
{
	$idseq	= shift;
	$program	= shift;
	$numbergene = shift;

	if(@_)
	{
		$idseq     {idseq     } = $_[0];
		$program   {program   } = $_[1];
		$numbergene{numbergene} = $_[2];
	}
	# SQL para buscar o melhor HIT de cada gene
	my $BestHits= "SELECT numbergene,idsimilarity,nunAcesso,descrition,score,evalue,MAX(score)
			   FROM   similarity s
			   INNER  JOIN aminoacids  a On s.idaminoacids= a.idaminoacids
			   INNER  JOIN transcripty t On a.idtranscipty= t.idtranscripty
			   WHERE  t.program='$program' AND t.idseq='$idseq' AND t.numbergene ='$numbergene'";

	#Prepara a SQL para ser executada
	my $sth = $db->prepare($BestHits);

	# Executa a SQL
	$sth->execute(); # Executa a sql
	# Recupera os dados
	$dados = $sth->fetchall_arrayref();
	#Retirna os dados
	return $dados;
}

########################################################################
# Método para buscar o numero de genes de um contig/fragmento de 
# sequência
########################################################################
sub Genes
{
	$idseq	= shift;
	$program	= shift;

	if(@_)
	{
		$idseq  {idseq  } = $_[0];
		$program{program} = $_[1];
	}
	# SQL para buscar os genes de cada contig, perceba que são os numeros de genes
	# por exemplo g1, g2, g3 e etc...
	my $genes= "SELECT DISTINCT numbergene
			FROM   similarity s
			INNER  JOIN aminoacids  a On s.idaminoacids= a.idaminoacids
			INNER  JOIN transcripty t On a.idtranscipty= t.idtranscripty
			WHERE  t.program='$program' AND t.idseq='$idseq'";

	my $sth = $db->prepare($genes);
	$sth->execute();
	$dados = $sth->fetchall_arrayref();

	return $dados;
}
########################################################################
# Método para buscar todos os hits de cada gene
########################################################################
sub AllHitsGenes
{
	$idseq	= shift;
	$program	= shift;
	$numbergene = shift;

	if(@_)
	{
		$idseq     {idseq     } = $_[0];
		$program   {program   } = $_[1];
		$numbergene{numbergene} = $_[2];
	}
	# SQL para buscar o melhor HIT de cada gene
	my $consenso= "SELECT numbergene,idsimilarity,nunAcesso,descrition,score,evalue
			   FROM   similarity s
			   INNER  JOIN aminoacids  a On s.idaminoacids= a.idaminoacids
			   INNER  JOIN transcripty t On a.idtranscipty= t.idtranscripty
			   WHERE  t.program='$program' AND t.idseq='$idseq' AND t.numbergene ='$numbergene'";

	#Prepara a SQL para ser executada
	my $sth = $db->prepare($consenso);

	# Executa a SQL
	$sth->execute(); # Executa a sql
	# Recupera os dados
	$dados = ();
	$dados = $sth->fetchall_arrayref();
	#Retirna os dados
	return $dados;
}

########################################################################
# Método para gerar o consenso de todos os genes, por meio da análise de
# do melhor hit de cada gene
########################################################################
sub Consenso
{
	$idseq= shift;

	if(@_)
	{
		$idseq{idseq} = $_[0];
	}

	my $consenso="SELECT s.nunAcesso,t.program,t.numbergene,s.score,s.evalue,s.descrition,s.idaminoacids
			  FROM   similarity s
			  INNER  JOIN aminoacids  a On s.idaminoacids= a.idaminoacids
			  INNER  JOIN transcripty t On a.idtranscipty= t.idtranscripty
			  WHERE  t.idseq='$idseq'
			  AND descrition<>'NOHITS'
			  GROUP  BY t.program,t.numbergene
			  HAVING MAX(score)
			  ORDER BY nunAcesso, t.program, t.numbergene";

	# Prepara a SQL para ser executada
	my $sth = $db->prepare($consenso);

	# Executa a SQL
	$sth->execute(); # Executa a sql
	# Recupera os dados
	$dados = $sth->fetchall_arrayref();
	# Retirna os dados
	return $dados;
}

########################################################################
# Busca todos os resultados provenientes de uma análise que não encontra
# ram nehuma similaridade
########################################################################
sub NOHITS
{
	$idseq= shift;

	if(@_)
	{
		$idseq{idseq} = $_[0];
	}

	my $noHit = "SELECT t.program,t.numbergene,b.description,b.id_aminoacids 
			FROM noHit b 
			INNER JOIN aminoacids a On b.id_aminoacids=a.idaminoacids 
			INNER JOIN transcripty t On a.idtranscipty= t.idtranscripty 
			WHERE t.idseq='$idseq' AND b.description='NOHITS' 
			GROUP BY t.program,t.numbergene 
			ORDER BY t.program, t.numbergene";

	# Prepara a SQL para ser executada
	my $sth = $db->prepare($noHit);

	# Executa a SQL
	$sth->execute(); # Executa a sql
	# Recupera os dados
	$dados = $sth->fetchall_arrayref();
	# Retirna os dados
	return $dados;
}

return 1;
