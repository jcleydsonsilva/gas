#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Using in the system modules
use CGI;
use Layout;
use GeneFindController;
# Instancing the modules Objects
my $layout 	= new Layout;
my $page   	= new CGI;

# Usando módulos
print $page->header(-charset=>'utf-8');

# Using methods the Objects
print $page  ->start_html("  ");

	use CGI::Session  qw/-ip-match/;
	use SessionController;
	my $session	   = CGI::Session->load() or die CGI::Session->errstr();
	if($session->is_expired)
	{
		$session->header(-location=>'gsm.pl');
	}
	elsif($session->is_empty)
	{
		$session->header(-location=>'gsm.pl');
	}
	else
	{
		# check login
		@session = SessionController::checkSession();
		print "<b>$session[1]</b>";
	}
	print $layout->menu($session[3]);
# Header of cadaster
print '<center><H2><br>';
	print 'Busca por Genes Homologos <br>';
print '</center></H2>';
print '<br>';

# 


# Close From
print $page->end_form();

# Show rodapé
print $layout->lower();

# Finalize page
print $page->end_html;
