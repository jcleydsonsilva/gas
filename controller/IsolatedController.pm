package ::IsolatedController;

# Using local modules
use lib '/var/www/gsm/model/';
use IsolatedSample;
use Locality;
use Switch;
use Connect;

# Using IsolatedSample Class, Locality class, Sequence Class
$isolated  = new IsolatedSample;
$locality  = new Locality;

# Connect database
	my $dbh = Connect::db;

# Method New
sub new 
{
	return bless {}, shift || ref shift;
}

## Method for Cadaster, update, delete for the formularium institution the data.
## The action is sent by param operation
sub dataInsert
{
	my $first		= shift;
	my $idIsolate	= shift;
	my $isolateCode	= shift;
	my $idLocality	= shift;
	my $iduser		= shift;
	my $specie		= shift;
	my $host		= shift;
	my $collectionDate= shift;
	my $information	= shift;
	my $state		= shift;
	my $city		= shift;
	my $latitude	= shift;
	my $longitude	= shift;
	my $operation	= shift;
	my $iduser		= shift;

	if(@_)
	{
		$idIsolate->{idIsolate}			= $_[0];
		$isolateCode->{isolateCode}		= $_[1];
		$idLocality->{idLocality}		= $_[2];
		$iduser->{iduser}				= $_[3];
		$specie->{specie}				= $_[4];
		$host->{host}				= $_[5];
		$collectionDate->{collectionDate}	= $_[6];
		$information->{information}		= $_[7];
		$state->{state}				= $_[8];
		$city->{city}				= $_[9];
		$latitude->{latitude}			= $_[10];
		$longitude->{longitude}			= $_[11];
		$operation->{operation}			= $_[12];
		$iduser->{iduser}				= $_[13];
	}

	switch ($operation)
	{
		case "Register"
		{
			my $sql = "INSERT INTO `locality` (state,city,latitude,longitude) VALUES('$state','$city','$latitude','$longitude')";
			my $sth = $dbh->prepare($sql);
			if($sth->execute)
			{
				$id = "SELECT LAST_INSERT_ID() as id";
				my $sth = $dbh->prepare($id);
				$sth->execute;

				# Take last insert id
				my @id = $sth->fetchrow_array;
				if($id[0] != '')
				{
				my $sql = "INSERT INTO `isolatedSample` (codeIsolated,idLocality,idUser,specie,host,dataCollection,addinfo)
						VALUES('$isolateCode','$id[0]','$iduser','$specie','$host','$collectionDate','$information')";

				my $sth = $dbh->prepare($sql);
				$sth->execute;
				}
				return 'Register successfully!!';
			}
			else
			{
				return 'Unsuccessfully in the register!';
			}
		
		}
		case "Update"
		{
			my $sqlu = "UPDATE `locality` SET state='$state', city='$city', latitude='$latitude', longitude='$longitude' 
					WHERE idLocality='$idLocality'";

			my $sth = $dbh->prepare($sqlu);
			$sth->execute();

			my $sqlu2 = "UPDATE `isolatedSample` SET codeIsolated='$isolateCode', idLocality='$idLocality',idUser='$iduser',specie='$specie', host='$host', dataCollection='$collectionDate', addinfo='$information' WHERE idisolatedSample='$idIsolate'";

			my $sth = $dbh->prepare($sqlu2)
			if($sth->execute);
			{
				$result = 'Updated successfully!';
			}
			return "$result\t";
		}
	}
}

sub selectAll
{
	my $search = shift;
	$search = $_[0];
	
	my $sql = "SELECT * FROM  isolatedSample
				  INNER JOIN locality ON isolatedSample.idLocality = locality.idLocality
				  WHERE codeIsolated like '%$search%' or specie like '%$search%' or host like '%$search%' or dataCollection like '%$search%' 
				  OR addinfo like '%$search%' OR state like '%$search%' OR city like '%$search%'"; 

	my $sth = $dbh->prepare($sql);
	if($sth->execute())
	{
		$result = $sth->fetchall_arrayref();
		return $result;
	}
	else
	{
		return 'Não foi possível selecionar a selecionar!';
	}
}

sub selectIsolate
{
	my $idIsolated = shift;
	$idIsolated = $_[0];

	my $sql = "SELECT * FROM isolatedSample
				  INNER JOIN locality ON isolatedSample.idLocality = locality.idLocality
				  WHERE idisolatedSample=$idIsolated";

	my $sth = $dbh->prepare($sql);
	if($sth->execute())
	{
		$result = $sth->fetchall_arrayref();
		return $result;
	}
	else
	{
		return 'Unsuccessfully in the query!';
	}
}

$rc = $dbh->disconnect;

return 1;
