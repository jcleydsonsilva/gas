#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos necessários o sistema
use CGI;
use Layout;
use Bio::Perl;

# Instancing the modules Objects
	my $layout 	= new Layout;
	my $page   	= new CGI;

# Using methods the Objects
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Search in Foreign Banks");
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
		print 'Search in Foreign Banks';
	print '</center></H2>';

	if( $page->param('action') eq '' )
	{
		print '<center>';
		print $page->startform(-method =>'POST',-action =>'',-name=>'search');
			print '<br>';
			print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					@database = (Genbank,Embl,Swissprot,RefSeq);
					print $page->popup_menu(-name=>'database', -values=>\@database);	
					print $page->textfield (-name=>'query' ,-value=>$search,-size=>'20');
					print $page->submit    (-name=>'action',-value=>'Procurar')."<br>";
					print "Entre com o numero de identificação ou de acesso dos sequintes bancos: <br>";
					print "Genbank - Embl - Swissprot - RefSeq";
				print '<td>';
			print '</tr>';
		print $page->end_form();
		print '</table>';
		print '</center>';
	}

	if($page->param('action') ne '')
	{
	
		$seq_object = get_sequence($page->param('database'),$page->param('query'));

		$nunAcesso = $seq_object->accession_number;
		@sequence = $seq_object->seq;            
		
		print "<br>";
			print "Consulta realizada no\n" .  $page->param('database') . "<br>";
		print "<br>";
			print "Numero de Acesso: $nunAcesso\n"."<br>";
		print "<br>";
			print "Descrição: "    .$seq_object->desc."\n <br>";
		print "<br>";
			print "Identificação: ".$seq_object->display_name ."\n <br>";
		print "<br>";
			print "Comprimento: "  .$seq_object->length ."\n <br>";
		print "<br>";
		print "Sequência\n"."<br>";
		print "<br>";
		print "<div class='sequence'>";
		foreach $i(0..$#sequence)
		{

			#para separar a linha a cada 10 bases
			@partes = split(/([ACGTN]{90})/                ,$sequence[$i]);
			@partes = split(/([ACDEFGHIKLMNPQRSTVWY*]{90})/,$sequence[$i]);

			# Para imprimir cada bloco de 10 bases
			foreach $j(0..$#partes)
			{
				# Verifica se vazio e imprime o fragmentos
				if($partes[$j] ne "")
				{
					print "$partes[$j]"."<br>";
				}
			}
			
		}
		print "</div>";

		print "<br>";
		print	"<a href='' ref='ordinalpos=2'>Blast</a>  "; 
		print	"<a href='' ref='ordinalpos=2'>Fasta</a>  ";
		print	"<a href='' ref='ordinalpos=2'>Nova Busca</a>  ";

	}


# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
