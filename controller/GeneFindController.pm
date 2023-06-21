#!/usr/bin/perl -w

package GeneFindController;

# Using local modules
use lib '/var/www/gsm/model/';
use Connect;
	# Objeto para connexão para base de dados
	$db = Connect::db;

# Busca os dados de anotações referentes a uma sequencia de DNA
sub QueryData
{
	$idseq  = shift;
	$program= shift;
	if(@_)
	{
		$idseq  {idseq  }= $_[0];
		$program{program}= $_[1];
	}
	# SQL para buscar todos os genes preditos de uma determinada sequência
	$sql = "SELECT region,chain,start,stop,numGene
		  FROM gene
		  WHERE idseq=$idseq AND program='$program'";

	#Prepara a busca
	my $sth = $db->prepare($sql);

	# Buscará na base de dados todos os genes que foram preditos
	$sth->execute(); # Executa a sql
	$dados = $sth->fetchall_arrayref();
	# Retorna todos os dados encontrados
	return $dados;
}
# Busca os programas que foram anotadores de uma determinada sequência 
sub Programas
{
	# Recebe o id da sequencia de DNA
	my $idsequence = shift;
	if(@_)
	{
		$idsequence{idsequence} = $_[0];
	}
	# SQL para buscar os programas que foram anotados 
	$sql ="SELECT DISTINCT program
		 FROM gene
		 WHERE idseq='$idsequence'
		 ORDER BY program ASC	 ";

	#Prepara a busca
	my $sth = $db->prepare($sql);

	# Buscará todas as sequências que estão cadastradas no banco de dados, 
	$sth->execute; # Executa a sql
	$dados = $sth->fetchall_arrayref;
	# Retorna os programas que foram anotados
	return $dados;
}

return 1;
