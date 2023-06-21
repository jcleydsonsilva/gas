#!/usr/bin/perl -w

package ::SequenceController;

# Using local modules
use lib '/var/www/gsm/model/';
use Connect;
use File;
use Switch;
use CGI;
use Manipulation;

my $db   = Connect::db;
my $file = new File;

sub new
{
    return bless {}, shift || ref shift;
}

sub seqInsert
{
	my $first	= shift;
	my $idIsolate   = shift;
	my $type	= shift;
	my $isolateCode = shift;
	my $filename    = shift;
	my $operation   = shift;

	# Take the data across the function
	if(@_)
	{
		$idIsolate  ->{idIsolate}  = $_[0];
		$type       ->{type}       = $_[1];
		$isolateCode->{isolateCode}= $_[2];
		$filename   ->{filename}   = $_[3];
		$operation  ->{operation}  = $_[4];
	}


	if($operation eq 'Register')
	{
		# Query idIsolate case not get
		if($idIsolate eq '' or $filename eq 'false' )
		{				
			CGI::redirect(-URL =>'/var/www/gsm/view/public/sequenceRegister.pl');
		}
		else
		{
			
		# Send file name
		$file->setNameSequence($filename);

		# Retrieve data on format FASTA on hashing 	
		my %hashOnFasta = $file->readFile();

		# Retrieve the sequence indenticator
		@seqIdenticator = keys %hashOnFasta;

			foreach $i (@seqIdenticator)
			{
				# Define the consult sql
				$sql = "INSERT INTO `sequence` (idIsolate,type,seqIdenticator,sequence) 
					  VALUES('$idIsolate','$type','$i','$hashOnFasta{$i}')";
				my $sth = $db->prepare($sql);

				if($sth->execute)
				{
					$ret = 'Cadastrado com sucesso!'
				}
				else
				{
					$ret = 'Não foi possivel cadastrar';
				}
			}
		}
	}
	return "$ret - $prot";
}

sub selectIsolate
{
	my $id = shift;
	$id    = $_[0];

	$sql = "SELECT idisolatedSample,codeIsolated,specie FROM `isolatedSample` WHERE idisolatedSample='$id'";

	my $sth = $db->prepare($sql);

	if($sth->execute())
	{
		$result = $sth->fetchall_arrayref();
		return $result;
	}
}

return 1
