package userController;

# Using local modules
use lib '/var/www/gsm/model/';
use DBI;
use Connect;

# Objtcts
	my $dbh = Connect::db;

## Method for Cadaster, update, delete for the formularium institution the data.
## The action is sent by param operation
sub userCrud
{
	my $id		=shift;
	my $name		=shift;
	my $email		=shift;
	my $institution	=shift;
	my $department	=shift;
	my $laboratory	=shift;
	my $adviser		=shift;
	my $level		=shift;
	my $password	=shift;
	my $operation	=shift;

	if(@_)
	{
		$id{id}			 =$_[0];
		$name{name}			 =$_[1];
		$email{email}		 =$_[2];
		$institution{institution}=$_[3];
		$department{department}	 =$_[4];
		$laboratory{laboratory}	 =$_[5];
		$adviser{adviser}		 =$_[6];
		$level{level}		 =$_[7];
		$password{password}	 =$_[8];
		$operation{operation}	 =$_[9];
	}

# Case cadaster
	if($operation eq 'Register')
	{
		my $status = 1;
		my $sql = "INSERT INTO `user`(name,email,institution,department,laboratory,adviser,level,password,status) VALUES('$name','$email','$institution','$department','$laboratory','$adviser','$level','$password','$status')";

		my $sth = $dbh->prepare($sql);

		if($sth->execute())
		{
			return 'c';
		}
		else
		{
			return 'Unsuccessfully in the register!';
		}
	}
	elsif($operation eq 'Update')
	{
		my $sql = " UPDATE `user`
				SET name='$name',email='$email',institution='$institution',department='$department',laboratory='$laboratory',adviser='$adviser',level='$level',password='$password' 
				WHERE iduser='$id'";

		my $query = $dbh->prepare($sql);

		if($query->execute)
		{
			return 'Updated successfully!';
		}
		else
		{
			return 'Unsuccessfully in the register!';
		}
	}
	elsif($operation eq 'Delete')
	{
		my $status = 0;
		my $sql = "UPDATE status='$status' WHERE iduser='$id'";
		my $query = $dbh->prepare($sql);

		if($query->execute)
		{
			return 'Deleted successfully!';
		}
		else
		{
			return 'Unsuccessfully in the delete!';
		}
	}
	else
	{
		return '';
	}
}

## Method for select institution by id the institution
sub selectUser
{
	my $iduser =shift;
	if(@_)
	{
		$iduser{iduser} =$_[0];
	}

	# Limpa @datauser
	@datauser = ();
	my $sql = " SELECT * FROM `user` 
			WHERE iduser='$iduser'";
	my $query = $dbh->prepare($sql);

	$query->execute();
	@datauser = $query->fetchrow_array();

	return @datauser;

}

# Method for select institution with parameter like
sub selectAll
{
	my $search = shift;

	if(@_)
	{
		$search{search} = $_[0];
	}

	$sql = "SELECT * FROM `user` 
		  WHERE name LIKE '%$search%' 
		  OR email LIKE '%$search%' 
		  OR department LIKE '%$search%' 
		  OR laboratory LIKE '%$search%' 
		  OR adviser LIKE '%$search%'";

	$query = $dbh->prepare($sql);

	if($query->execute())
	{
		$result = $query->fetchall_arrayref();
		return $result;
	}
	else
	{
		return 'Unsuccessfully in the select!!';
	}
}

	$rc = $dbh->disconnect;

return 1;
