#!/usr/bin/perl

package ::LocalBlast;

use Switch;

sub setProgram
{
  my $program = shift;
  if(@_)
  {
  	$program->{program} = $_[0];
  }
}


sub getProgram
{
  my $program = shift;
  	return $program->{program}; 
}


sub setDatabase
{
  my $database = shift;
  if(@_)
  {
  	$database->{database} = $_[0];
  }  
}


sub getDatabase
{
  my $database = shift;
  	return $database->{database};
}

sub setQuery
{
	my $query = shift;
	if(@_)
	{
		$query->{query} = $query;
	}
}

sub getQuery
{
	my $query = shift;
	return $query;
}

sub setResult
{
  my $result = shift;
  if(@_)
  {
  	$result->{result} = $_[0];
  }
}

sub getResult
{
  my $result = shift;
  	return $result->{result};
}

return 1;
