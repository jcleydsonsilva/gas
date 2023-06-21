#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos necessários o sistema
use CGI;
use Layout;
use Manipulation;
use GeneFindController;
use AnotacaoController;
use SequenceViewController;
use CGI::Session ;
use SessionController;

# Instancing the modules Objects
my $layout 	= new Layout;
my $page   	= new CGI;

# Using methods the Objects
print $page->header(-charset=>'utf-8');
print $page->start_html("Resultado da Busca");
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
		@session = SessionController::checkSession();
		print "<b>$session[1]</b>";
	}
	print $layout->menu($session[3]);

# Header of cadaster
	print '<center><H2><br>';
		print 'Visualizar Anotação <br>';
	print '</center></H2>';
	print '<br><br>';
		
# Recebe o valor passado via get
  	$idseq = $page->param('idseq'); 
# Show Sequence
	$result = SequenceViewController::QuerySeq($idseq);

	#########################################################################
	# Imprimindo as informações sobre os isolados
	#########################################################################
	foreach $s (@$result)
	{
		# Conta quantidade de pares de base
		$comprimento = length(@$s[14]);
		# Passando sequencia para uma variável scalar
		$sequence	 = @$s[14];
		# Passando as bases para um array
		@bases = split(//,$sequence);

		# Monta na telas as informações dos isolados
		print 'Codigo do Isolado:' .' '. @$s[1]  . '<br>' ;
		print '<br>';
		print 'Especie		:' .' '. @$s[3]  . '<br>' ;
		print '<br>';
		print 'Indentificador	:' .' '. @$s[13] . '<br>' ;
		print '<br>';
		print 'Comprimento	:' .' '. $comprimento  . '<br>' ;
		print '<br>';
		print '<center>';
		print "<a href='?idseq=$idseq&predict=predict'	style=text-decoration:inherit color: red;> Exons	</a>";
		print "<a href='?idseq=$idseq&caract=caract'	style=text-decoration:inherit color: red;> Genes 	</a>";
		print "<a href='?idseq=$idseq&consc=consc'	style=text-decoration:inherit color: red;> All Genes	</a>";
		print "<a href='?idseq=$idseq&nohit=nohit'	style=text-decoration:inherit color: red;> No HITS	</a>";
		print '</center>';
		print "<hr>";
	}

	#########################################################################
	# Imprimindo as informações sobre os genes de cada fragmnento de DNA
	# Tais Como:
	#  - Genes Preditos de cada programa de predição de genes
	#  - O melhor Hit de cada gene por cada programa
	#########################################################################
	if( $page->param('predict') ne '')
	{
		########################################################################
		# Apresenta na tela todos os genes preditos pelod programas
		########################################################################
		$programas = GeneFindController::Programas($idseq);
		print "<br>";
		print "<center><table border='0,5' width='30%'>";
		print "Genes Preditos pelos programas <br>";
		print "<br>";
		foreach $i (@$programas)
		{
			print "<a href='?idseq=$idseq&predict=predict&program=@$i[0]' style=text-decoration:none> @$i[0] </a> \t\t";
		}
		if($page->param('program') ne '')
		{	
			# Busca os dados de anotações
			$dados = GeneFindController::QueryData($idseq,$page->param('program'));
			print "<br>";
			print "<tr align=center><td>Região</td><td>Fita</td><td>Inicio</td><td>Termino</td><td>Gene</td> </tr><br>";
			foreach $i (@$dados)
			{
				print "<tr>
					<td>@$i[0]</td>
					<td>@$i[1]</td>
					<td>@$i[2]</td>
					<td>@$i[3]</td>
					<td>@$i[4]</td>
					</tr>";
			}
		}
		print "</table></center>";
	}
	########################################################################
	# Esse trecho aprsenta na tela o melhor hit de cada gene por cada pro
	# grama
	########################################################################
	elsif(( $page->param('caract') eq 'caract'))
	{
		@programas = ();
		$programas  = GeneFindController::Programas($idseq);
		my $program = $page->param('program');
		print "<br>";
		print "<center><table border='0,5' width='30%'>";
		print "Melhor Hit de cada gene <br>";
		print "<br>";
		print "<font color=green> $program </font></center>";
		print "<br>";
		print "<br>";
		foreach $i (@$programas)
		{
			print "<a href='?idseq=$idseq&caract=caract&program=@$i[0]' style=text-decoration:none> @$i[0] </a> \t\t";
		}
		if($page->param('program') ne '' && $page->param('gene') eq '')
		{
			print "<tr align=center><td>Gene</td><td>Acesso</td><td>Descrição</td><td>Score</td><td>E-value</td><td>Vizualizar</td></tr><br>";
			$genes = AnotacaoController::Genes($idseq,$page->param('program'));
			foreach $g (@$genes)
			{
				my $program = $page->param('program');
				@hits = ();
				$hits = AnotacaoController::BestHits($idseq,$page->param('program'),@$g[0]);
				foreach $h (@$hits)
				{
					print "<tr>
						<td>@$h[0]</td>
						<td>@$h[2]</td>
						<td>@$h[3]</td>
						<td>@$h[4]</td>
						<td>@$h[5]</td>
						<td><a href='Anotacao.pl?idseq=$idseq&program=$program&gene=@$g[0]'><img src='imagens/browse.png'> </a></td></tr>";
				}
			}
		}
		print "</table></center>";
	}
	########################################################################
	# Apresenta na tela todos os hits de um único gene de um programa
	########################################################################
	elsif($page->param('gene') ne '' && $page->param('consc') eq '')
	{
		my $idseq	= $page->param('idseq')  ;
		my $program	= $page->param('program');
		my $gene	= $page->param('gene')   ;

		print "<br>";
		print "<center><table border='0,5' width='30%'>";
		print "Todos Hits de cada gene <br>";
		print "<br>";
		print "<tr align=center><td>Gene</td><td>Acesso</td><td>Descrição</td><td>Score</td><td>E-value</td></tr><br>";
		print "<font color=green> Programa $program gene $gene! </font></center>";
		print "<br>";

		$hits = AnotacaoController::AllHitsGenes($idseq,$program,$gene);
		foreach $h (@$hits)
		{
			print "<tr>
			<td>@$h[0]</td>
			<td>@$h[2]</td>
			<td>@$h[3]</td>
			<td>@$h[4]</td>
			<td>@$h[5]</td>
			<td><a href=''>  
			</a></td></tr>";
		}
		print "</table></center>";
	}
	########################################################################
	# Apresenta um consenso de todos os genes encontrados pelos programas
	# ordenados pelo numero de acesso
	########################################################################
	elsif($page->param('consc') ne '')
	{
		print "<center><table border='0,5' width='30%'>";
		print "Todos os melhores Hits de cada gene de cada programa";
		print "<tr align=center> <td>Programa</td><td>Gene</td><td>Acesso</td><td>Descrição</td><td>Score</td><td>E-value</td> <td>Anotação</td></tr>";

		my $idseq = $page->param('idseq');

		@hits = ();
		$hits = AnotacaoController::Consenso($idseq);
		foreach $h (@$hits)
		{
			print "<tr><td>@$h[1]</td> <td>@$h[2]</td> <td>@$h[0]</td> <td>@$h[5]</td> <td>@$h[3]</td> <td>@$h[4]</td> <td><a href='genes.pl?gene=@$h[6]&free=free'> <img src='imagens/browse.png'></a></td></tr>";
		}
		print "</table></center>";
	}
	elsif($page->param('nohit') ne '')
	{
		print "<center><table border='0,5' width='30%'>";
		print "Todos os No Hits de cada gene de cada programa";
		print "<tr align=center> <td>Gene</td><td>Programa</td><td>Descrição</td><td>Anotação</td></tr>";

		my $idseq = $page->param('idseq');

		@hits = ();
		$hits = AnotacaoController::NOHITS($idseq);
		foreach $h (@$hits)
		{
			print "<tr>
				<td>@$h[1]</td>
				<td>@$h[0]</td>
				<td>@$h[2]</td>
				<td><a href='genes.pl?gene=@$h[3]&free=free'> <img src='imagens/browse.png'></a></td></tr>"
		}
		print "</table></center>";
	}

# Encerra o formulário
	$page->end_form();
	print '<br>';

# Exibe o rodapé
	print $layout->lower();

# Finaliza a página
	print $page->end_html();
