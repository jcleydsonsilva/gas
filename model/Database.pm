#!/usr/bin/perl

package ::Database;

use lib '/var/www/gsm/model';
use strict;
use warnings;
use Connect;

my $dbh = Connect::db;

# constructor class
sub new {
    return bless {}, shift || ref shift;
}


# Insert, Delete, Update, Select
sub insertInstituition{
	
	my $institution	= shift;
	my $email	= shift;
	my $departament = shift;
	my $laboratory  = shift;
	
	if(@_){
  
	        $institution->{institution}= $_[0];
                $email->{email}		   = $_[1];
                $departament->{departament}= $_[2];
                $laboratory->{laboratory}  = $_[3];
	}
	
	my $sql = "INSERT INTO `institution` (nameInstitution,emailInstitution,departament,laboratory) VALUES('$institution','$email','$departament','$laboratory')";
	my $query = $dbh->prepare($sql);

	if($query->execute){
		return 'Instituição cadastrada com suscesso';
	}else{
		return 'não foi possível cadastrar a instituição';
	}

}

# Function update Institution
sub updateInstitution{

        my $institution	= shift;
	my $email	= shift;
	my $departament = shift;
	my $laboratory  = shift;
	my $id          = shift;
	
	if(@_){
  
	        $institution->{institution}= $_[0];
                $email->{email}		   = $_[1];
                $departament->{departament}= $_[2];
                $laboratory->{laboratory}  = $_[3];
                $id->{id}                  = $_[4];
	}
        
	my $sql = "UPDATE `institution` SET nameInstitution='$institution', emailInstitution='$email', $departament='$departament', laboratory='$laboratory' WHERE idinstitution='$id'";

	my $query = $dbh->prepare($sql);
        if($query->execute){
                return 'Instituição atualizada com suscesso';
        }else{
                return 'Não foi possível atualizar a instituição';
        }

}

# Function select Institution
sub selectInstituion{

	my $id          = shift;
	
	if(@_){
                $id->{id}= $_[0];
        }
        
	my $sql = "select * from `institution` WHERE idinstitution='$id' ORDER BY idinstitution";
	
	my $query = $dbh->prepare($sql);
        if(my @result = $query->execute){
                return @result;
        }else{
                return 'Não foi possível selecionar a instituição';
        }

# Function delete Institution
sub deleleInstituion{
	  
        my $id = shift;
	
	if(@_){
                $id->{id}= $_[0];
        }
        
        my $sql = "DELETE FROM `institution` WHERE idinstitution = '$id'";

        my $query = $dbh->prepare($sql);
        if($query->execute){
                return 'Instituição  excluída com suscesso';
        }else{
                return 'Não foi possível deletar a instituição';
        }
}
  
sub disconnect{

	DBI->disconnect();
}  
  
}
return 1;
