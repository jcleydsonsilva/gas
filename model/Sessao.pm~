package ::Sessao;

# Módulo responsável por fazer controle de sessão
use CGI;
use CGI::Session;

# Método pata iniciar uma sessão
sub StarSession
{
	my $id   =shift;
	my $name =shift;
	my $email=shift;
	my $level=shift;

	if(@_)
	{
		$id{id}	 =$_[0];
		$name{name}	 =$_[1];
		$email{email}=$_[2];
		$level{level}=$_[3];
	}

	my $cgi = new CGI;
	my $session = new CGI::Session("driver:File", undef,{Directory=>"/tmp"});
	my $cookie = $cgi->cookie(CGISESSID => $session->id);
	print $cgi->header(-cookie=>$cookie);
	$session->expire('+24h');
	$session->flush();

	$session->param(-name=>'iduser',-value=>"$id");
	$session->param(-name=>'name'  ,-value=>"$name");
	$session->param(-name=>'email' ,-value=>"$email");
	$session->param(-name=>'level' ,-value=>"$level");

	return 'Ok';
}

# Abre uma sessão existente e coleta dados da sessão
sub valid
{
	#my $cgi = CGI->new;
	#my $sessid = $cgi->cookie('CGISESSID');
	my $session = new CGI::Session("driver:File",undef, {Directory=>'/tmp'});

	if($session->param('iduser') ne '' && $session->param('name'))
	{
		@dados=();
		push(@dados,$session->param('iduser'));
		push(@dados,$session->param('name'));
		push(@dados,$session->param('email'));
		push(@dados,$session->param('level'));
		push(@dados,'Ok');
		return @dados;
	}
	else
	{
		@dados=();
		push (@dados,'False');
		return @dados;
	}
}

# Abre uma sessão existente e fecha
sub DelSession
{

	my $cgi = new CGI;
	my $session = new CGI::Session("driver:File", undef,{Directory=>"/tmp"});
	$id = $session->param('iduser');

	@out =();
	push(@out,$id);
	push(@out,'Ok');

	my $cookie = $cgi->cookie(CGISESSID => '0');
	print $cgi->header(-cookie=>$cookie);
	$session->expire('-1m');
	$session->flush();

	return @out;
}
return 1
