# Classe para controlar a busca por sequencias e isolados
# Autor: José Cleydson Ferreira da Silva
# Data: 03/07/2011 - Versão 1
# Atualizações:
#	- 

package ::SequenceQueryController;

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos para conexão e para tratamento de casos
use Connect;
use Switch;

	$dbh = Connect::db;

sub RunQuery
{
	my $query = shift;
	my $inicio= shift;
	my $maximo= shift;

	if(@_)
	{
		$query-> {query} 	= $_[0];
		$inicio->{inicio} = $_[1];
		$maximo->{maximo} = $_[2];
	}

	$sql = " SELECT  codeIsolated, idisolatedSample,specie, host, dataCollection, addinfo, state, city,
		           latitude, longitude, idsequence, type, seqIdenticator
		   FROM  sequence 
		   INNER JOIN isolatedSample on sequence.idIsolate   = isolatedSample.idIsolatedSample
		   INNER JOIN locality       on locality.idLocality  = isolatedSample.idLocality
		   WHERE codeIsolated   	like '%$query%' or specie  		like '%$query%' or host  like '%$query%'
		   	   or dataCollection	like '%$query%' or addinfo 		like '%$query%' or state like '%$query%' 
		   	   or city 			like '%$query%' or seqIdenticator 	like '%$query%' LIMIT $inicio,$maximo";

	if($query ne '')
	{
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
	else
	{
		return 'Não foi possível selecionar!';
	}
}

sub ContadorSeq
{
	my $query = shift;

	if(@_)
	{
		$query->{query} = $_[0];
	}

	$sql = " SELECT  codeIsolated, idisolatedSample,specie, host, dataCollection, addinfo, state, city,
				seqIdenticator
		   FROM  sequence 
		   INNER JOIN isolatedSample on sequence.idIsolate   = isolatedSample.idIsolatedSample
		   INNER JOIN locality       on locality.idLocality  = isolatedSample.idLocality
		   WHERE codeIsolated   	like '%$query%' or specie  		like '%$query%' or host  like '%$query%'
		   	   or dataCollection	like '%$query%' or addinfo 		like '%$query%' or state like '%$query%' 
		   	   or city 			like '%$query%' or seqIdenticator 	like '%$query%'";

	my $sth = $dbh->prepare($sql);
	if($sth->execute())
	{
		$total  = $sth->fetchall_arrayref();
		$count = 0;
		foreach $i (@$total)
		{
			$count++; 
		}
		return $count;
	}
	else
	{
		return 'Não foi possível selecionar!';
	}
}
	$rc = $dbh->disconnect;
return 1
