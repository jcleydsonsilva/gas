package ::SessionController;

# Using local modules
use lib '/var/www/gsm/model/';
use Sessao;
use Connect;

	my $dbh   	= Connect::db;

# Method for valid user
sub loginValid
{
	my $emailform	= shift;
	my $passwordform	= shift;
	if(@_)
	{
		my $emailform    = $_[0];
		my $passwordform = $_[1];
	}
	
	# Data compare the form
	my $sql = "SELECT iduser,name,email,password,level,status
			FROM user WHERE email='$emailform' 
			AND password='$passwordform'";

	my $query = $dbh->prepare($sql);
	
	$query->execute();
	@result = $query->fetchrow_array();

	if($passwordform eq "$result[3]" && $result[5] != 0)
	{
		$out = Sessao::StarSession($result[0],$result[1],$result[2],$result[4]);
		my $time = localtime();
		my $description = 'input';
		my $entrada = "INSERT INTO log_user (iduser,data,description) VALUES('$result[0]','$time','$description')";

		# Prepara a execução da SQL
		my $sth = $dbh->prepare($entrada);

		# Executa a SQL
		$sth->execute() or warn('Erro na inserção da busca!');
		return $out;
	}
	else
	{
		return 'False';
	}
}

sub checkSession
{
	@out = Sessao::valid();
	return @out;
}

#Fechar a sessão
sub closeSession
{
		@out = Sessao::DelSession;

		my $time = localtime();
		my $description = 'output';
		my $entrada = "INSERT INTO log_user (iduser,data,description) VALUES('$out[0]','$time','$description')";

		# Prepara a execução da SQL
		my $sth = $dbh->prepare($entrada);

		# Executa a SQL
		$sth->execute() or warn('Erro na inserção da busca!');

	return $out[1];
}
	$rc = $dbh->disconnect;
return 1;
