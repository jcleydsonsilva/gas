#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI;
use CGI::Session  qw/-ip-match/;
use Layout;
use BlastController;

# Instancing the modules Objects
my $layout 	        = new Layout;
my $page   	        = new CGI;
my $session	        = new CGI::Session;
my $blastController = new BlastController;

# Usando modulos
print $page->header(-charset=>'utf-8');

# Using methods the Objects
	print $page->start_html("Blast Resut");
	print $layout->header();

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
        print 'Blast Resut';
    print '</center></H2>';

# Show blast
	
	$result = $blastController->ResultBlast();
	print $result;
   
# Show rodapé
    print $layout->lower();

# Finalize page
    print $page->end_html();
