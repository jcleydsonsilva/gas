#!/usr/bin/perl

package ::Entity;

use warnings;


sub setName
{
  my $name = shift;
  if(@_){
  	$name->{name} = $_[0];
  }
}


sub getName
{
  my $name = shift;
  	return $name->{name};
}


sub setEmail
{
  my $email = shift;
  if(@_){
  	$email->{email} = $_[0];
  }
}


sub getEmail
{
  my $email = shift;
  	return $email->{email};
}


sub setAction
{
  my $action = shift;
  if(@_){
  	$action->{action} = $_[0];
  }
}


sub getAction
{
  my $action = shift;
  	return $action->{action};
}


sub setId
{
  my $id = shift;
  if(@_){
  	$id->{id} = $_[0];
  }
}

sub getId
{
  my $id = shift;
  	return $id->{id};
}

return 1;
