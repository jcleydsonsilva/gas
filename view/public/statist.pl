#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI;
use Layout;
use Chart::Pie;
use Chart::OFC;
use CGI::Session;
use SessionController;
use AnnotationTableController;

# Instancing the modules Objects
	my $page	= new CGI;
	my $layout	= new Layout;

# Iniciang Tradution the page
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Genome System Mining");

# Using methods the Objects
	print $layout->header();

	my $session	 = CGI::Session->load() or die CGI::Session->errstr();
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
	print '<center><H2><br>';
		print 'Results of annotation of genes';
	print '</center></H2><br>';

	if($page->param('idiso') eq '')
	{
		# Exibirá todas as espécies que que estão cadastradas no banco de dados
		print "<center><table>";
		print "<tr align=center><td>Code</td><td>Spacie</td><td>Show</td></tr>";
		my $specie = AnnotationTableController::getSpecie();
		foreach $i (@$specie)
		{

				print "<tr>";
					print "<td>@$i[1]</td>";
					print "<td>@$i[2]</td>";
					print "<td><a href='statist.pl?idiso=@$i[0]&specie=@$i[2]'><img src='imagens/browse.png'> </a></td>";
				print "</tr>";
		}
		print "</center></table>";
	}
	else
	{
		my $idiso = $page->param('idiso');
		print '<center><H3>';
			print $page->param('specie');
		print '</center></H3>';

		# Bloco para exibição de informações relacionadas aos preditores de genes
		my @total = AnnotationTableController::getEstProgram($idiso);
		print "<h3>Gene Predictores</h3>";
		print "<table>";
		print "<tr align=center><td>Program</td><td>Total of Genes</td><td>pre Annotation</td><td>No pre annotation</td><td>No hits</td>";
			foreach $t (@total)
			{
				print "<tr tr align=center>";
					print "<td>@$t[0]</td>";
					print "<td>@$t[1]</td>";
					print "<td>@$t[2]</td>";
					my $noannotation = @$t[1] - @$t[2];
					print "<td>$noannotation</td>";
					print "<td>@$t[3]</td>";
				print "</tr>";
			}
		print "</tr>";
		print "</table>";

=haed
		@labels = [GeneID,SNAP,GlimmerHMM,Augustus];
		@data   = [15000,22000,55000,27000];
		my $graph = Chart::Pie->new(300,200);
		my $file = "/var/www/files/out/graph_pie_BP.png";
		my @labels = keys(%graph_BP);
		$graph->set(title => "Chart", transparent => '1', graph_border => 0, png_border => 1);
		my @data = values(%graph_BP);
		$graph->add_dataset(@labels);
		$graph->add_dataset(@data);
		$graph->png($file);
=cut
	}


# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
	$page->delete();
