#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI qw(:standard);
use Layout;
use SessionController;

# Instancing the modules Objects
	my $page	= new CGI;
	my $layout	= new Layout;

# Iniciang Tradution the page
	print $page->header;
	print $page->start_html(-title=>"Autentication GSM",
					-style=>{'src'=>'public/estilo/Estilo.css'}
					);

# Using methods the Objects
	print "<br><br><br><br><br><br>";
	print "<br><br><br><br><br><br>";
	print "<br><br><br><br><br>";

# Valid  data
	if( $page->param('email') && $page->param('password') && $page->param('action') )
	{
		my $email 	 = $page->param('email');
		my $password = $page->param('password');

		$out = SessionController::loginValid($email,$password);
		
		if($out eq 'Ok')
		{
			$page->redirect(-url=>'public/index.pl');
		}
	}

# Title page 
	print "<center><h2>Genome System Mining</h2></center>";

	if($out eq 'False')
	{
		print "<center>User  or password incorrec!</center>"; 
	}
# Login Formularium
	print "<center><table>";
	print $page->startform(-method=>'POST',-action=>'',-name=>'login');

# Email Field
	print '<center>';
		print '<tr>';
			print '<td>';
				print 'Email  ';
				print '</td><td>';
				print $page->textfield(-name=>'email',-value=>$email,-size=>'20');
			print '</td>';
		print '</tr>';
	print '</center>';

# Password Field
		print '<center>';
		print '<tr>';
		print '<td>';
			print 'Password  ';
			print '</td><td>';
			print $page->password_field(-name=>'password',-value=>$password,-size=>'20');
			print '</td>';
		print '</tr>';
		print '</center>';
# Submint Button
		print '<center>';
			print '<tr>';
			print '<td>';
			print '</td><td>';
			print $page->submit(-name=>'action',-value=>'Go');
			print '</td>';
		print '</tr>';
		print '</center>';

# Close From
	print $page->end_form();
	print "</center></table>";

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
