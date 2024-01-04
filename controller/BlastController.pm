#!/usr/bin/perl -w

package ::BlastController;

# Using local modules
use lib '/var/www/gsm/model/';
use CGI;
use File;
use Switch;
use LocalBlast;

# Path for fasta file for query

$pathQuery = '/var/www/gsm/files/in/';

# Object the class
my $db   = Connect::db;
my $file = new File;

# Method new the class BlastController
sub new
{	
    return bless {}, shift || ref shift;
}

# runBlast Method the class BlastController  
sub RunBlast
{
	my $first	 = shift;
	my $database = shift;
	my $program  = shift;
	my $filename = shift;
	my $operation= shift;
	
	# Recebe os dados vindos do formulário
	if(@_)
	{
		$database ->{database} = $_[0]; 
		$program  ->{program}  = $_[1]; 
		$filename ->{filename} = $_[2]; 
		$operation->{operation}= $_[3]; 
	}

	# Trata os casos de operação. Aqui ele vai buscar ou limpar a tela 
	switch ( $operation )
	{
		# Case houver busca ele vai entar neste caso
		case 'Search'
		{
			if  ($database eq 'Microcyclus-Genome')
			{
				if($filename ne '')
				{	# Inicia o processo de busca por meio do metodo QueryBlast
					LocalBlast::QueryBlast($program,$filename);
				}
				else
				{
					return 'Não foi possível fazer o BLAST!';
				}
			}
			elsif($database eq 'Microcyclus-Trasncripty')
			{
				if($filename ne '')
				{
					# Inicia o processo de busca por meio do metodo QueryTranscripty
					LocalBlast::QueryTranscripty($program,$filename);
				}
				else
				{
					return 'Não foi possível fazer o BLAST!';
				}
			}
			elsif($database eq 'Microcyclus-Gene')
			{
				if($filename ne '')
				{
					# Inicia o processo de busca por meio do metodo QueryTranscripty
					LocalBlast::QueryGene($program,$filename);
				}
				else
				{
					return 'Não foi possível fazer o BLAST!';
				}
			}
			elsif ($database eq 'NCBI')
			{
				if($filename ne '')
				{
					# Inicia o processo de busca por meio do metodo BlastNCBI na base de dados do NCBI que esta configurada no computador local
					$result = LocalBlast::BlastNCBI($program,$filename);
				}
				else
				{
					return 'Não foi possível fazer o BLAST!';
				}
			}
			elsif ($database eq 'Mycosphaerellaceae')
			{
				if($filename ne '')
				{
					# Inicia o processo de busca por meio do metodo BlastMycosphaerellaceae na base de dados de fungos do genero BlastMycosphaerellaceae que esta configurada no computador local
					$result = LocalBlast::BlastMycosphaerellaceae($program,$filename);
				}
				else
				{
					return 'Não foi possível fazer o blast!';
				}
			}
			elsif($database eq 'Nr-aa/nt')
			{
				if($filename ne '')
				{
					# Inicia o processo de busca por meio do metodo BlastMycosphaerellaceae na base de dados de fungos do genero BlastMycosphaerellaceae que esta configurada no computador local
					$result = LocalBlast::BlastNr($program,$filename);
				}
				else
				{
					return 'Não foi possível fazer o blast!';
				}
			}
			else
			{
				return 'Não foi possível fazer o blast!'
			}
		}
		case 'Clear'
		{	
			# Redireciona para a a página principal se clicar em Clear
			CGI::redirect(-URL=>'http://localhost/gsm/view/public/');
		}
	}
}

sub ResultBlast
{
	# Pega o resultado da blast e retorna
	$result = LocalBlast::BlastResult();
	return $result;
}

return 1
