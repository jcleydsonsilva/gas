#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos necessários o sistema
use CGI;
use POSIX;
use Layout;
use SequenceQueryController;

# Instancing the modules Objects
my $layout= new Layout;
my $page  = new CGI;

# Usando modulos
print $page->header(-charset=>'utf-8');

# Using methods the Objects

	print $page->start_html("Resultado da Busca");
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
        print 'Resultado da Busca <br>';
    print '</center></H2>';
    print '<br>';

# Envia os valores para o controller para que seja feita a busca e direcionado para a página de resultados

	$query = $page->param('query');

	if($page->param('pagina') eq '')
	{
		$pagina = 1;
	}
	else
	{
		$pagina = $page->param('pagina');
	}
	# Calculando pagina anterior  
	my $menos = ($pagina - 1);

	# Calculando pagina posterior  
	my $mais = ($pagina + 1);
	
	# Maximo de registros por pagina  
	$maximo = 50;

	# Ceil arredonda para cima
	$total = SequenceQueryController::ContadorSeq($query);
	my $pgs = ceil( $total / $maximo );

	# Calculando o registro inicial  
	$inicio = $pagina - 1;
	$inicio = $maximo * $inicio;

	if ($pgs > 1)
	{
		# Mostragem de pagina  
		if ($menos > 0)
		{
			print "<a href=\"?pagina=$menos&query=$query\" class='texto_paginacao' align=”Left”> <<< </a> ";
		}
		# Listando as paginas  
			for ($i = 1; $i <= $pgs; $i++)
			{
				if ($i eq $pagina)
				{
					print "  <a href=\"?pagina=$menos&query=$query\" class='texto_paginacao'>$i de $pgs</a>";
				}
			}
		if ($mais <= $pgs)
		{
			print "   <a href=\"?pagina=$mais&query=$query\" class='texto_paginacao'> >>> </a>";
		}
	}

	# Conta os resultados no total da minha query
	print '<br>';
	print '<br>';

	if($query ne '')
	{
		# Busca os dados na base de dados
		$resultQuery = SequenceQueryController::RunQuery($query,$inicio,$maximo);

		# Imprime os resultados na tela
		foreach $i (@$resultQuery)
		{
			print "<a href='SequenceView.pl?idseq=@$i[10]'> @$i[12] - @$i[2] - @$i[3]</a>  <br>";
			print "Specie: @$i[2] - Host: @$i[3]<br><br>";
			print "<a href='Anotacao.pl?idseq=@$i[10]' ref='ordinalpos=2'>Genes Preditos</a>   ";
			print "<a href='SequenceView.pl?idseq=@$i[10]'>Overview</a>  <br>";
			print "<br>";
		}
	}

	# Calculando pagina anterior  
	$menos = $pagina -1;

	# Calculando pagina posterior  
	$mais = $pagina +1;

	# Ceil arredonda para cima
	$pgs = ceil($total / $maximo);

	if ($pgs > 1)
	{
		# Mostragem de pagina  
		if ($menos > 0)
		{
			print "<a href=\"?pagina=$menos&query=$query\" class='texto_paginacao'> <<< </a> ";
		}
		# Listando as paginas  
			for ($i = 1; $i <= $pgs; $i++)
			{
				if ($i eq $pagina)
				{
					print "  <a href=\"?pagina=$menos&query=$query\" class='texto_paginacao'>$i de $pgs</a>";
				}
			}
		if ($mais <= $pgs)
		{
			print "   <a href=\"?pagina=$mais&query=$query\" class='texto_paginacao'> >>> </a>";
		}
	}

	print '<br>';

# Exibe o rodapé
	print $layout->lower();

# Finaliza a página
	print $page->end_html();
