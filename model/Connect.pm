#!/usr/bin/perl

package ::Connect;

use DBI;

sub db
{
    my $dbh = shift();
    my $dbh = DBI->connect("DBI:mysql:gsm:localhost:3306",'266955root548','7845espilce2525') or die ("Não foi possível fazer conexão: " . $DBI::errstr);
    return $dbh;
}

return 1;
