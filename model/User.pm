#!/usr/bin/perl

package ::User;

# Method for
sub new
{
	my $class = shift();
	my $self = {};
	bless($self, $class);
	return $self;
}

# Method for
sub setUsername
{
	my $username = shift;
	if(@_)
	{
		$username->{username} = $_[0];
	}
}

# Method for
sub getUsername
{
  my $username = shift;
	return $username->{username};
}

# Method for
sub setEmail
{
	my $email = shift;
	if(@_)
	{
		$email->{email} = $_[0];
	}
}


sub getEmail
{
	my $email = shift;
	return $email->{email};
}

# Method for
sub setInstitution
{
	my $institution = shift;
	if(@_)
	{
		$institution->{institution} = $_[0];
	}
}


sub getInstitution
{
	my $institution = shift;
	return $institution->{institution};
}

# Method for
sub setAction
{
	my $action = shift;
	if(@_)
	{
		$action->{action} = $_[0];
	}
}

# Method for
sub getAction
{
	my $action = shift;
	return $action->{action};
}

# Method for
sub setLevel
{
	my $level = shift;
	if(@_)
	{
		$level->{action} = $_[0];
	}
}

# Method for
sub setLevel
{
	my $level = shift;
	return $level->{level};
}

# Method for
sub setId{
	my $id = shift;
	if(@_)
	{
		$id->{id} = $_[0];
	}
}

# Method for
sub getId
{
	my $id = shift;
	return $id->{id};
}

# Method for
sub setAdviser
{
	my $mastermind = shift;
	if(@_)
	{
		$mastermind->{mastermind} = $_[0];
	}
}

# Method for
sub getAdviser
{
	my $mastermind = shift;
	return $mastermind->{mastermind};
}

# Method for
sub setPassword
{
	my $password = shift;
	if(@_)
	{
		$password->{password} = $_[0];
	}
}

# Method for 
sub getPassword
{
	my $password = shift;
	return $password->{password};
}

# Method for
sub setStatus
{
	my $status = shift;
	if(@_)
	{
		$status->{status} = $_[0];
	}
}

# Method for 
sub getStatus
{
	my $status = shift;
	return $status->{status};
}

# Method for
sub setDepartament
{
	my $department = shift;
	if(@_)
	{
		$department->{department} = $_[0];
	}
}

# Method for 
sub getDepartament
{
	my $department = shift;
	return $department->{department};
}

# Method for
sub setLaboratory
{
	my $laboratory = shift;
	if(@_)
	{
		$laboratory->{laboratory} = $_[0];
	}
}

# Method for 
sub getLaboratory
{
	my $laboratory = shift;
	return $laboratory->{laboratory};
}

return 1;
