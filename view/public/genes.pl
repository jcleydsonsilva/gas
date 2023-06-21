#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos necessários o sistema
use CGI;
use Layout;
use GeneController;

# Instancing the modules Objects
my $layout	= new Layout;
my $page  	= new CGI;

# Using methods the Objects
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Searching for Genes");
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

# Espaços abaixo do menu
	print "<br>\n";

	####################################################################################
	# 
	####################################################################################
	if($page->param('query') eq '' && $page->param('free') eq '')
	{
		# Header of cadaster
		print '<center><H2><br>';
			print 'Searching for Genes';
		print '</center></H2>';

		print '<center>';
		print '<table>';
		print $page->startform(-method =>'POST',-action =>'',-name=>'search');
			print '<br>';
			print '<tr>';
				print '<td>';
					print '';
				print '</td><td>';
					print $page->textfield(-name=>'query',-value=>$search,-size=>'45');
					print $page->submit   (-name=>'action',-value=>'Query');
				print '<td>';
			print '</tr>';
			print $page->end_form();
		print '</table>';
		print '</center>';
		print '<center> <font color="green">        </font></center>';
		print '<center> <font color="green">Ex.: GD0214, Microcyclus, Micro, ulei </font></center>';
	}
	####################################################################################
	# Exibe a informação do genoma na tela de resultado de busca
	####################################################################################
	$query = $page->param('query');

	if($query ne '' && $page->param('action') eq 'Query')
	{
		print "<br>";
		print "<center> <font color=green> Resultado da busca por $query </font></center>";
		print "<br>";
		print "<a href='genes.pl'> New Search </a><br>";
		$result = GeneController::SearchEngine($query);

		$anterior = 'vazio';
		foreach $i (@$result)
		{
			if(@$i[1] eq '')
			{
				print 'Nenhum resultado encontrado!';
			}
			else
			{
				if($anterior ne @$i[1])
				{
					print "<br>";
					print "<a href=?gene=@$i[0]&free=free> @$i[1] </a><br>";
					print "<br>";
					print "@$i[2] - @$i[3] 		<br>"."\n";
					print "@$i[4] 			<br>"."\n";
					$anterior = @$i[1];
				}
				}
		}
	}
	####################################################################################
	# Exibe a informação completa do gene
	####################################################################################
	if($page->param('gene') && $page->param('free') ne '')
	{
		$idaminoacids = $page->param('gene');

		# Buscar as informações do gene para popular a tela
		my $bestHit 	= GeneController::BestHit	  ($idaminoacids);
		my $descGene	= GeneController::DescGene	  ($idaminoacids);
		my $proteinFamily	= GeneController::ProteinFamily ($idaminoacids);
		my $geneOntology	= GeneController::GeneOntology  ($idaminoacids);
		my $keeg		= GeneController::KeegProtein	  ($idaminoacids);
		my $ortho		= GeneController::KeegOrtho	  ($idaminoacids);
		my $pathway		= GeneController::KeegPathway	  ($idaminoacids);
		my @transAmino	= GeneController::GetTransAmi   ($idaminoacids);
		my $structure	= GeneController::GetStructure  ($idaminoacids);
		
		# Inicia o processo de montagem de dados na tela
		
		print "<center><h2>Gene Overview</h2></center>";
		print "<br>";
		print "<a href='genes.pl'> New Search </a><br>";
		print "<br>";
		print "<h3>Description</h3>\n";
		print "<table>";
		foreach $i (@$descGene)
		{
			print "<tr><td>Location:		</td><td>@$i[0]</td></tr>\n";
			print "<tr><td>Program: 		</td><td>@$i[1]</td></tr>\n";
			print "<tr><td>Number the Gene:	</td><td>@$i[2]</td></tr>\n";
			$program=@$i[1],$numGene=@$i[2];
			
		}
		print "</table>";

		####################################################################################
		## Informações sobre os exons
		####################################################################################

		my $exon	= GeneController::AllExon($idaminoacids,$program,$numGene);

		$tam = @$exon;

		print "<h3>Exons</h3>\n";
		print "<tr><td>Number exons: </td><td>$tam</td></tr>\n";
		print "<br>";
		print "<br>";
		print "<table>";
		print "<tr>";
			print "<td>Number</td><td>Chain</td><td>Start</td><td>Stop</td>\n";
		print "</tr>";


		foreach $e (@$exon)
		{
			print "<tr>";
				print "<td>@$e[0]</td> <td>@$e[1]</td> <td>@$e[2]</td> <td>@$e[3]</td>";
			print "<tr>";

		}
		print "<table>";

		####################################################################################
		## Descrição do melhor hit
		####################################################################################
		print "<h3>Best Hit</h3>\n";
		print "<table>";
		print "<tr>";
			print "<td>Number</td><td>Description</td><td>Score</td><td>Evalue</td><td>Database</td>\n";
		print "</tr>";
		foreach $b (@$bestHit)
		{
			if(@$b[6] eq 'swissprot')
			{
				print "<tr>";
				print "<tr><td><a href='http://www.uniprot.org/uniprot/@$b[1]' target='blank'> @$b[1]</a></td><td>@$b[2]</td><td>@$b[3]</td><td>@$b[4]</td><td>@$b[5]</td>";
				print "</tr>";
			}
			else
			{
				print "<tr>";
				print "<tr><td><a href='http://www.ncbi.nlm.nih.gov/protein/@$b[1]' target='blank'> @$b[1]</a></td><td>@$b[2]</td><td>@$b[3]</td><td>@$b[4]</td><td>@$b[5]</td>";
				print "</tr>";
			}
			$accessNumber = @$b[1];
		}
		print "</table>";

		####################################################################################
		##  Genes encontrados com outros preditores
		####################################################################################
		print "<h3>Other similar Genes </h3>\n";

		$number = GeneController::AllGenes($accessNumber);
		print "<table>";
		foreach $n (@$number)
		{
			if(@$n[1] =~ $program)
			{}
			else
			{
				print "<tr>";
				print "<td><a href='genes?gene=@$n[0]&free=free' target='blank'>@$n[1]<a/></td>";
				print "<tr>";
			}
		}
		print "</table>";
		####################################################################################
		## Descrição de dominio de proteína consultadas nas bases de dados do INTERPRO
		####################################################################################
		print "<h3>Protein Family</h3>\n";
		print "<table>";
		print "<tr>";
			print "<td>Method</td><td>Number</td><td>Description</td><td>Interpro</td><td>Interpro Description</td>\n";
		print "</tr>";
		foreach $p (@$proteinFamily)
		{
			print "<tr>";
				print "<tr><td>@$p[2]</td><td>@$p[3]</td><td>@$p[4]</td><td><a href='http://www.ebi.ac.uk/interpro/DisplayIproEntry?ac=@$p[5]' target='blank'>@$p[5]</a></td><td>@$p[6]</td>";
			print "</tr>";
		}
		print "</table>";

		####################################################################################
		## Descrição sobre Gene Ontology
		####################################################################################
		print "<h3>Gene Ontology</h3>\n";
		print "<table>";
		print "<tr>";
			print "<td>Method</td><td>Number</td><td>Description</td>\n";
		print "</tr>";
		foreach $g (@$geneOntology)
		{
			print "<tr>";
				print "<tr><td>@$g[1]</td>\t<td>@$g[2]</td><td><a href='http://amigo.geneontology.org/cgi-bin/amigo/term_details?term=@$g[3]' target='blank'>@$g[3]</td>";
			print "</tr>";
		}
		print "</table>";

		####################################################################################
		## Descrição sobre estrutura tridimencional
		####################################################################################
		print "<h3>Structure</h3>\n";
		print "<table>";
		print "<tr>";
			print "<td>Number</td><td>Description</td><td>Evalue</td>\n";
		print "</tr>";
		$i=0;
		foreach $s (@$structure)
		{
			if($i<1)
			{
				print "<tr>";
				print "<td><a href='http://www.ebi.ac.uk/pdbe-srv/view/entry/@$s[0]' target='blank'>@$s[0]</a></td>
					<td>@$s[1]</td>
					<td>@$s[2]</td>";
				print "</tr>";
			}$i++;
		}

		print "</table>";

		####################################################################################
		## Descrição dos resultados das Vias metabólicas
		####################################################################################
		print "<h3>Metabolic pathways</h3>\n";
		print "<h4>Access number KEEG</h4>\n";
		print "<table>";
		# Bloco se refere a proteína encontrada no Keeg
		print "<tr>";
			print "<td>Keeg</td><td>Description</td>\n";
		print "</tr>";
		foreach $k (@$keeg)
		{
			print "<tr>";
			print "<td><a href='http://www.genome.jp/dbget-bin/www_bget?@$k[0]' target='blank'> @$k[0]</a></td>					 <td>@$k[1]</td>";
			print "</tr>";
			# Define um parâmentro para o link das vias metabólicas
			$pathparam = @$k[0];
		}
		print "</table>";
		# Bloco se refere a Orthology encontrado no Keeg
		print "<h4>Orthology</h4>\n";
		print "<table>";
		print "<tr>";
			print "<td>Orthology</td> <td>Description</td> <td>Enzyme</td>\n";
		print "</tr>";
		foreach $o (@$ortho)
		{
			print "<tr>";
			print "
					<td><a href='http://www.genome.jp/dbget-bin/www_bget?ko:@$o[0]' target='blank'> @$o[0]</a> </td>
					<td>@$o[1]</td>
					<td><a href='http://www.genome.jp/dbget-bin/www_bget?ec:@$o[2]' target='blank' >@$o[2]</a></td>
				";
			print "</tr>";
		}
		print "</table>";

		# Bloco se refere aos Pathways encontrados no Keeg
		print "<h4>Pathways</h4>\n";
		print "<table>";
		print "<tr>";
			print "<td>Pathways</td><td>Description</td>\n";
		print "</tr>";
		foreach $p (@$pathway)
		{
			print "<tr>";
			print "
					<td><a href='http://www.genome.jp/kegg-bin/show_pathway?@$p[0]+$pathparam' target='blank'> @$p[0] </a></td>
					<td>@$p[1]</td>
				";
			print "</tr>";
		}
		print "</table>";

		####################################################################################
		## Sequência do transcrito e aminoácido do gene 
		####################################################################################

		# Bloco se refere aos Pathways encontrados no Keeg
		print "<h3>Sequence Aminocids - Transcripty</h3>\n";
		print "<h4>AA Seq</h4>\n";
		print "<table>";
		print "<tr>";
		print "<td>";
		print "<div class='sequence'>";
		@partes = split(/([ACDEFGHIKLMNPQRSTVWY*X]{90})/,$transAmino[0]);
		foreach $j (0..$#partes)
		{
			# Verifica se vazio e imprime o fragmentos
			print "$partes[$j]\n";
		}
		print "</div>";
		print "</td>";
		print "</tr>";
		print "</table>";

		print "<h4>NT Seq</h4>\n";
		print "<table>";
		print "<tr>";
		print "<td>";
		print "<div class='sequence'>";
		@partes = split(/([ACGTNXacgtnx]{90})/,$transAmino[1]);
		foreach $j (0..$#partes)
		{
			# Verifica se vazio e imprime o fragmentos
			print "$partes[$j]\n";
		}
		print "</div>";
		print "</td>";
		print "</tr>";
		print "</table>";
		
		####################################################################################
		# Pega a primeira posição do primeiro exon e a ultima posição do ultimo exon
		# Esse trecho de algoritmo visa encontrar o gene como um todo inclindo as bordas de
		# exons e regiões promotras, tatabox e e região 5' 
		####################################################################################
		if($tam > 1)
		{
			my $control =0;
			foreach $ei (@$exon)
			{
				if($control==0)
				{
					$inicio_gene = @$ei[2];
					$chain = @$ei[1];
				}
				if($control== $tam-1)
				{
					$fim_gene = @$ei[3];
				}
				$control++;
			}
		}
		else
		{
			foreach $ei (@$exon)
			{
				$inicio_gene = @$ei[2];
				$chain = @$ei[1];
				$fim_gene = @$ei[3];
			}		
		}
		my $exonwithintron=GeneController::GetExonIntron($inicio_gene,$fim_gene,$idaminoacids,$chain);
		print "<h4>Sequence with promoter region </h4>\n";
		print "<table>";
		print "<tr>";
		print "<td>";
		print "<div class='sequence'>";
		@partes = split(/([ACGTNXacgtnx]{90})/,$exonwithintron);
		foreach $j (0..$#partes)
		{
			# Verifica se vazio e imprime o fragmentos
			print "$partes[$j]\n";
		}
		print "</div>";
		print "</td>";
		print "</tr>";
		print "</table>";
		
		
	}
	print $page->end_form();

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
