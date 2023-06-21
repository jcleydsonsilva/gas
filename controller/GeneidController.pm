#!/usr/bin/perl -w

# Classe para controlar consulta ao geneid
package ::GeneidController;

# Using local modules
use lib '/var/www/gsm/model/';

use GeneidAnotation;

# inicia a busca por anotacao
sub RunGeneidAnotation
{
	$sequence = shift;
	$filename = shift;
	$profile  = shift;

	if(@_)
	{
		$sequence{sequence} = $_[0];
		$filename{filename} = $_[1];
		$profile {profile } = $_[2];
	}

	$anotationGeneid = GeneidAnotation::PrintAnotation($sequence,$filename,$profile);

	return $result;
}

return 1;
