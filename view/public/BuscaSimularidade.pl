#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI;
use Layout;
use SequenceController;
use IsolatedController;
use BuscaSimilaridadeController;

# Instancing the modules Objects
	my $page	= new CGI;
	my $layout	= new Layout;
	my $sequence= new SequenceController;

# Iniciang Tradution the page
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Similarity & Homology");

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
		print 'Similarity & Homology';
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
	# Busca
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
	# 
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
		}

		# Form for crud institution
		print "<center>";
		print $page->start_form(-method=>'POST',-action=>'BuscaSimularidade.pl',-name=>'muBlast');
		print '<fieldset>';
		print '<legend> Similarity & Homology</legend>';
		print '<table>';

		# Campo oculto com mo id do isolado
		print '<tr>';
			print '<td>';
				print $page->hidden(-name=>'idisolate',-value =>$idisolated);
			print '</td>';
		print '</tr>';
		# Database Field
		print '<tr>';
			print '<td>';
				print 'Database  ';
				print '</td><td>';
				@database 	= ('swissprot','nr','pdb','refseq_protein');
				@program 	= ('blastp','blastx');
				@org		= ('Fungi','Eukaryota');
				print $page->popup_menu(-name=>'database', -values=>\@database),"Programa  ", $page->popup_menu(-name=>'program', -values=>\@program);
				print "Organismo  ", $page->popup_menu(-name=>'org', -values=>\@org);
			print '</td>';
		print '<br>';	
		print '</tr>';

		# Input File FASTA Field
		print '<tr>';
			print '<td>';
				print 'Isolado';
				print '</td><td>';
				print $page->textfield(-name=>'isolado',-value=>$isolateCode,-size=>'45');
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
		$codeisolado= $page->param('idisolate');
		$database   = $page->param('database' );
		$programa   = $page->param('program'  );
		$organismo	= $page->param('org'      );

		$resultado = BuscaSimilaridadeController::QueryBlast($programa,$database,$codeisolado,$organismo);

		print "<center> <font color='red'> $resultado </font></center>";
	}

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
