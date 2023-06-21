#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI qw(:standard);
use Layout;
use CGI::Session;
use SessionController;

# Instancing the modules Objects
	my $page	= new CGI;
	my $layout	= new Layout;

# Iniciang Tradution the page
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Genome System Mining");

# Using methods the Objects
	print $layout->header();

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
		$out = SessionController::closeSession();

		if($out eq 'Ok')
		{
			if($session->is_expired)
			{
				$session->header(-location=>'gsm.pl');
			}
			elsif($session->is_empty)
			{
				$session->header(-location=>'gsm.pl');
			}
			$page->redirect(-url=>'gsm.pl');
		}
		else
		{
			$session->header(-location=>'index.pl');
		}
	}

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
