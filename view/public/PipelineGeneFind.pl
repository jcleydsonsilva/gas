#!/usr/bin/perl

=head
	Pipeline para anotação de regiões promotoras.
	Esse pipeline permite a utilização de programas para predição de exeons,
	que constam nos registros de isolados cadastrados. A notação permite armazenar
	em uma base de dados todas as posições de regiões de exons nas sequencias que
	se encontram armazenadas na base de dados.
	
Autor: José Cleydson Ferreira da Silva
		Universidade Federal de Viçosa / Faculdade de Viçosa
		Departamento de Fitopatologia
		Labotatório de Biologia de Populações de Fitógenos
Data: 29/09/2011
	
Sob Orientação: Prof. Eduardo S. G. Mizubuti
Modificações:
		- Data/Hora:
		- Modificação:

=cut

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Using in the system modules
use CGI;
use Layout;
use IsolatedController;
use SequenceController;
use PipelineGeneFindController;
use Switch;

# Instancing the modules Objects
my $layout	= new Layout;
my $page	= new CGI;
my $seqController = new SequenceController;

	# Usando modulos
	print $page->header(-charset=>'utf-8');

	# Using methods the Objects
	print $page  ->start_html("");
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
		print 'Gene Prediction<br>';
	print '</center></H2>';
	print '<br>';

=head
	Analisa a possibilidade de haver um código do isolado, para fazer a busca dos códigos
	e isolados para colocá-los no formulário, para ser submetidos.
=cut
	if($page->param('idIsolate') ne '' && $page->param('action') eq '')
	{
		my $id     = $page->param('idIsolate');
		$isolated  = $seqController->selectIsolate($id);
		foreach $i (@$isolated)
		{
			$idIsolate      = @$i[0];
			$isolateCode    = @$i[1];
	 	}
	}

=head
	Análisa se não há nenhuma busca para exibir o formulário de busca por isolados
=cut
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
		print '<center> <font color="#006400">Ex.: GD0214, Microcyclus, Micro, ulei </font></center>';
	}

=head1
	Verifica se há algum pedido de anotação vindo de uma requisição por POST, 
	Se houver será submetido para a anotação do de todas as sequências cadas-
	tradas e que estão vinculadas a um isolado.
=cut

	if($page->param('action') eq 'Anotar')
	{
		# Recebe os valores do formulario
		$idIsolate = $page->param('idIsolate');
		$program   = $page->param('program'  );
		
		# verifica se o isolado já foi anotado
		$resposta = PipelineGeneFindController::CheckAnotation($idIsolate,$program);

		if($resposta eq 'Ok')
		{
			# inicia o processo de busca pelos genes
			$output = PipelineGeneFindController::RunGeneFind($idIsolate,$program);
			print "<center> <font color='red'> $output </font></center>";;
		}
		else
		{
			print "<center> <font color='red'> $resposta </font></center>";
		}

		print "<center> <font color='red'><a href=PipelineGeneFind.pl>.:Clique aqui para anotar outro isolado:.</a> </font></center>";

	}

=head
	Verifica se há alguma buca para exibir o formário de anotação
=cut
	elsif($page->param('search') ne '')
	{
		$search = $page->param('search');
		print '<center>';
		print '<table>';
		print $page->startform(-method =>'POST',-action =>'',-name=>'search');
			print '<br>';
				print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					@program = ('Escolha um programa','GlimmerHMM','Geneid','Augustus','SNAP');
					print $page->hidden    (-name=>'idIsolate',-value =>$idIsolate);
					print $page->popup_menu(-name=>'program'  ,-values=>\@program );	
					print $page->textfield (-name=>'query'    ,-value =>$isolateCode,-size=>'20');
					print $page->submit    (-name=>'action'   ,-value =>'Anotar'  )."<br>";
				print '<td>';
			print '</tr>';
		print $page->end_form();
		print '</table>';
		print '</center>';
		print '<center> <font color="#006400"> Escolha um programa para anotar!</font></center>';
	}


=head
	Faz a busca por isolados conforme o contexto de busca.
	Está utilizando o controle do cadastro de insolados (IsolatedController)
	o uso deste controlador me permite herdar códigos sem que haja necessidade
	de códificar o mesmo código ou outro parecido.
=cut

#  Grid with data
if($search ne '' && $page->param('action') ne '' && $page->param('limpar') eq '')
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

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
