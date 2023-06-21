#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI qw(:standard);
use Layout;
use SessionController;

# Instancing the modules Objects
	my $page       = new CGI;
	my $layout     = new Layout;

# Iniciang Tradution the page
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Genome System Mining");

# Using methods the Objects
	print $layout->header();

	print "<a href='../autentication.pl'>LOGIN</a>";

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
