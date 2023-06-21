#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI;
use Layout;
use SequenceController;
use IsolatedController;
use FamilyGoController;

# Instancing the modules Objects
	my $page	= new CGI;
	my $layout	= new Layout;
	my $sequence= new SequenceController;

# Iniciang Tradution the page
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Protein Functional Analysis");

# Using methods the Objects
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
		print 'Protein Functional Analysis';
	print '</center></H2>';

	####################################################################################
	# Formulário para busca de isolados
	####################################################################################
	if($page->param('search') eq '' && $page->param('action') eq '')
	{
		print '<center>';
		print '<table>';
		print $page->startform(-method =>'POST',-action =>'',-name=>'search');
			print '<br>';
			print '<tr>';
				print '<td>';
					print '';
				print '</td><td>';
					print $page->textfield(-name=>'search',-value=>$search,-size=>'45');
					print $page->submit   (-name=>'action',-value=>'Search');
				print '<td>';
			print '</tr>';
			print $page->end_form();
		print '</table>';
		print '</center>';
		print '<center> <font color="green"> Escolha um isolado para anotar!       </font></center>';
		print '<center> <font color="green">Ex.: GD0214, Microcyclus, Micro, ulei </font></center>';
	}
	####################################################################################
	# Busca por isolados cadastrados na base de dados
	####################################################################################
	$search = $page->param('search');
	if($search ne '' && $page->param('action') eq 'Search' && $page->param('limpar') eq '')
	{
		$result = IsolatedController::selectAll($search);

		foreach $i (@$result)
		{
			if(@$i[1] eq '')
			{
				print 'Nenhum resultado encontrado!';
			}
			else
			{
				print '<hr>';
				print @$i[1] . ' - ' . @$i[4],"<br>";
				print @$i[5],"<br>";
				print @$i[9] . ' - ' . @$i[10],"<br>";
				print "<a href=?idIsolate=@$i[0]&search=$search&limpar=limpar> Anotar </a>";
			}
		}
	}
	####################################################################################
	# Busca o código do isolado
	####################################################################################
	if($page->param('idIsolate') ne '' && $page->param('action') eq '')
	{
		my $id     = $page->param('idIsolate');
		$isolated  = $sequence->selectIsolate($id);
		foreach $i (@$isolated)
		{
			$idIsolate      = @$i[0];
			$isolateCode    = @$i[1];
	 	}
	}
	#########################################################################################
	# O formulário abaixo pega o valor vindo na url e coloca os valor diretamente no formulário
	# pega o id do usuario que foi passado via GET na URL
	#########################################################################################
	if($page->param('idIsolate') ne '' && $page->param('action') eq '')
	{
		my $id    = $page->param('idIsolate');

		$dados = $sequence->selectIsolate($id);
		foreach $i (@$dados)
		{
			$idisolated     = @$i[0];
			$isolateCode    = @$i[1];
			$especie	    = @$i[2];
		}

		# Form for crud institution
		print "<center>";
		print $page->start_form(-method=>'POST',-action=>'',-name=>'');
		print '<fieldset>';
		print '<legend> Protein Family and Gene Ontology </legend>';
		print '<table>';

		# Campo oculto com mo id do isolado
		print '<tr>';
			print '<td>';
				$codigo = "$isolateCode - $especie";
				print $page->hidden(-name=>'isolate',-value =>$idisolated);
			print '</td>';
		print '</tr>';
		# Identificação do isolado a ser anotado
		print '<tr>';
			print '<td>';
				print 'Isolado';
				print '</td><td>';
				print $page->textfield(-name=>'isolado',-value=>$codigo,-size=>'45');
				print '<td>';
		print '</tr>';

	# Action button
			print '<tr>';
			print '<br>';
				print '<td>';
					print '    ';
				print '</td>';
				print '<td>';
				print '<center>';
				print '<table>';

				print '<br>';
					print $page->submit(-name=>'query',-value=>'Search');
					print $page->submit(-name=>'action',-value=>'Clear'   );
				print '</table>';
				print '</center>';
				print '</td>';
			print '</tr>';
		print '</table>';
		print '</fieldset>';
		print $page->end_form();
		print "</center>";
	}

	if($page->param('query') eq 'Search')
	{
		#Receber o svalor e chamar a função
		$idisolados = FamilyGoController::RunFamilyGo($page->param('isolate'));

		print "<center> <font color='red'> $resultado </font></center>";
	}

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
