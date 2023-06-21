#!/usr/bin/perl

package ::Locality;

# Locality Class
#

sub new
{
	$idLocality= shift;
	$city  	   = shift;
	$state 	   = shift;
	$latitude  = shift;
	$longitude = shift; 
	
	if(@_)
	{
		$idLocality->{idLocality}= $_[1];
		$city->{city}		 = $_[2];
		$state->{state}		 = $_[3];
		$latitude->{latitude}	 = $_[4];
		$longitude->{longitude}	 = $_[5];
	}
}

sub setIdLocality
{
	$idLocality = shift;
	if(@_)
	{
		$idLocality->{idLocality} = $_[0];
	}
}

sub getIdLocality
{
	$idLocality = shift;
	return $idLocality->{idLocality};
}

sub setIdCity
{
	$idCity = shift;
	if(@_)
	{
		$idCity->{idCity} = $_[0];
	}
}

sub getIdCity
{
	$idCity = shift;
	return $idCity->{idCity};
}

sub setCity
{
	$city = shift;
	if(@_)
	{
		$city->{city} = $_[0];
	}
}

sub getCity
{
	$city = shift;
	return $city->{city};
}

sub setState
{
	$state = shift;
	if(@_)
	{
		$state->{state} = $_[0];
	}
}

sub getState
{
	$state = shift;
	return $state->{state};
}

sub setLatitude
{
	$latitude = shift;
	if(@_)
	{
		$latitude->{latitude} = $_[0];
	}
}


sub getLatitude
{
	$latitude = shift;
	return $latitude->{latitude};
}

sub setLongitude
{
	$longitude = shift;
	if(@_){
		$longitude->{longitude} = $_[0];
	} 
}

sub getLongitude
{
	$longitude = shift;
	return $longitude->{longitude};
}

sub oneLocality
{
	$id = shift;
	if(@_)
	{
		$id->{id} = $_[0];
	}
	
	$sql = "select * from `cidade` where id_cidade='$id'";
	$query = $dbh->prepare($sql);

	if($query->execute())
	{
		$result = $query->fetchall_arrayref();
		return $result;
	}
}

return 1;
