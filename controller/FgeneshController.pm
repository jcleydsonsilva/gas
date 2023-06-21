#!/usr/bin/perl -w

package ::FgeneshController;

# Using local modules
use lib '/var/www/gsm/model/';
use Connect;
use File;
use Switch;
use AnotationFgenesh;

my $db   = Connect::db;
my $file = new File;

# inicia a busca por anotacao
sub RunAnotation
{
	my $database = shift;
	my $program	 = shift;
	my $filename = shift;
	
	if(@_)
	{
		$database->{database} = $_[0];
		$program ->{program } = $_[1];
		$filename->{filename} = $_[2];
	}

	switch ($program)
	{	
		case 'fgenesh'
		{
			if($program eq 'fgenesh')
			{
				# Configura o arquivo de saída

				AnotationFgenesh::QueryAnotation($program,$filename);
			}
			print $query;
			exit;
		
		}
	}
}

return 1;



