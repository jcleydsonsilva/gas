#!/usr/bin/perl

# Classe para controlar a busca por sequencias e isolados
# Autor: José Cleydson Ferreira da Silva
# Data: 03/07/2011 - Versão 1
# Atualizações:
#	- 

package ::SequenceViewController;

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos para conexão e para tratamento de casos
use Connect;
use Switch;

	$dbh = Connect::db;

sub QuerySeq
{
	my $idseq = shift;
	
	if(@_)
	{
		$idseq->{idseq} = $_[0];
	}

	$sql = " SELECT  name,codeIsolated, idisolatedSample,specie, host, dataCollection, addinfo, state, city,
		           latitude, longitude, idsequence, type, seqIdenticator, sequence
		   FROM  sequence 
		   INNER JOIN isolatedSample On sequence.idIsolate   = isolatedSample.idIsolatedSample
		   INNER JOIN locality	     On locality.idLocality  = isolatedSample.idLocality	
		   INNER JOIN user	     On isolatedSample.idUser= user.iduser	
		   WHERE idsequence = $idseq";

	my $sth = $dbh->prepare($sql);
	if($sth->execute())
	{
		$result = $sth->fetchall_arrayref();
		return $result;
	}
	else
	{
		return 'Não foi possível selecionar!';
	}
}	
return 1
