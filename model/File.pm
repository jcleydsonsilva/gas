#!/usr/bin/perl -w

# Class for files manipulation FASTA

package ::File;

# Define Path on the FASTA file 
my $pathSequence = '/var/www/gsm/files/';
my $nameFile;


sub new
{
	return bless {}, shift || ref shift;
}

# Define name on the FASTA file
sub setNameSequence
{
	$nameFile = shift;
	$nameFile = $_[0];
}

# All split on multiples data FASTA
sub readFile
{
	my %fasta;
	
	$file = "$pathSequence$nameFile";
		
	if (!open( INFILE,"<$file" ))
	{
		return "cannot open $nameFile";
	}
	else
	{
		# Abre o arquivo para leitura
		open(INFILE,"<$file");
		while ($line = <INFILE>)
		{
			chomp($line);
			# Ele pegará desde o inicio incluindo o sinal >, por causa da geração do arquivo fasta na hora de fazer as análises
			if( substr($line,0,1) eq '>' )
			{	
				$key = substr($line,0,30);
			}
			else
			{
				$fasta{$key} .= $line;
			}
		}
		close(INFILE);		
	}

	return %fasta;
}

return 1
