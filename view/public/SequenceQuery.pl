#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos necessários o sistema
use CGI;
use Layout;
use SessionController;
use SequenceQueryController;

# Instancing the modules Objects
my $layout 	= new Layout;
my $page   	= new CGI;

# Usando modulos
print $page->header(-charset=>'utf-8');

# Using methods the Objects
	print $page->start_html("Buscar sequencia");
	print $layout->header();

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
        print 'Sequence Search';
    print '</center></H2>';

# Form of search by institution    

	if( $page->param('search') eq '' )
	{
		print '<center>';
		print $page->startform(-method =>'POST',-action =>'ResultadoSequenceQuery.pl',-name=>'search');
			print '<br>';
			print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					print $page->textfield(-name=>'query' ,-value=>$search,-size=>'45');
	  	              	print $page->submit   (-name=>'action',-value=>'Search');
				print '<td>';
			print '</tr>';
		print $page->end_form();
		print '</table>';
		print '</center>';
	}

# Envia os valores para o controller para que seja feita a busca e direcionado para a página de resultados

	$query = $page->param('query');

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
