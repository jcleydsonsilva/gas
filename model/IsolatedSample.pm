#!/usr/bin/perl

package ::IsolatedSample;

sub new
{
	$isolateCode 	= shift;
	$specie			= shift;
	$dataCollection = shift;
	$responsable	= shift;
	$addInformation	= shift;
	if(@_)
	{
		$isolateCode    = $_[1];
		$specie         = $_[2];
		$dataCollection = $_[3];
		$responsable    = $_[4];
		$addInformation = $_[5];
	}
}

sub setIdIsolateCode
{
    my $idIsolateCode =  shift;
    if(@_)
    {
        $idIsolateCode->{idIsolateCode} = $_[0];
    }
}

sub getIdIsolateCode
{
    $idIsolateCode =  shift;
    return $idIsolateCode->{idIsolateCode};
}

sub setIsolateCode
{
	my $isolateCode =  shift;
	if(@_)
	{
		$isolateCode->{isolateCode} = $_[0];
	}
}


sub getIsolateCode
{
	$isolateCode =  shift;
	return $isolateCode->{isolateCode};
}

sub setSpecie
{
  	my $specie = shift;
	
	if(@_)
	{
		$specie->{specie} = $_[0];
	}
}

sub getSpecie
{
    my $specie  = shift;
    return $specie->{specie};
}

sub setDateCollection
{
  	my $dataCollection = @_; # string : 
    
	if(@_)
	{
		$dataCollection->{dataCollection} = $_[0];
	}
}

sub getDateCollection
{
	my $dataCollection = shift;
	$dataCollection->{dataCollection};
}

sub setResponsible
{
	my $responsable = shift;

	if(@_)
	{
		$responsable->{responsable} = $_[0];
	}
}

sub getResponsible
{
	my $responsable = shift;
	return $responsable->{responsable};
}

sub setHost
{
	$host = shift;
	if(@_)
	{
		$host->{host} = $_[0];
	}
}

sub getHost
{
	$host = shift;
	return $host->{host};
}

sub setAddInformation
{
	my $addInformation = shift;
	if(@_)
	{
		$addInformation->{addInformation} = $_[0];	
	}
}

sub getAddInformation
{
	$addInformation = shift;
	return $addInformation->{addInformation};
}


return 1;
