#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Using in the system modules
use CGI;
use Layout;
use GeneidController;

# Instancing the modules Objects
my $layout 	= new Layout;
my $page   	= new CGI;

# Usando modulos
print $page->header(-charset=>'utf-8');

# Using methods the Objects
print $page  ->start_html(" geneid ");

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

# Caminho do arquivo
my $filePath = '/home/cleysinho/Dropbox/gsm/files/in/';

# Header of cadaster
	print '<center><H2><br>';
		print 'Geneid <br>';
	print '</center></H2>';
	print '<br>';

	if($page->param('action') eq 'Procurar' )
	{
		$sequence = $page->param ('seq'   );
		$filename = $page->upload('file'  );
		$profile  = $page->param ('prof'  );
		$output   = $page->param ('output');
		
		# undef may be returned if it's not a valid file handle
		if (defined $filename)
		{
			# Upgrade the handle to one compatible with IO::Handle:
			my $io_handle = $filename->handle;
			
			open (OUTFILE,'>>',$filePath.$filename);
			while ($bytesread = $io_handle->read($buffer,1024))
			{
		 		print OUTFILE $buffer;
			}
		}
	
		$filename = $filePath.$filename;

		GeneidController::RunGeneidAnotation($sequence,$filename,$profile,$output);
	}

# Formulario de dados
	print '<center>';
	print $page->start_form(-method=>'POST',-action=>'Geneid.pl',-name=>'geneid');

		print '<table>';

# Input File FASTA Field
			print '<tr>';
				print '<td>';
					print 'Arquivo Fasta';
					print '</td><td>';
				    print $page->filefield(-name=>'file', -size=>30);
				    print '<td>';
			print '</tr>';

# Opção de organismo modelo
			print '<tr>';
				print '<td>';
					print 'Organismo';
					print '</td><td>';
					@profile  =('arabidopsis.param'  ,'aspergillus.param','celegans.param' ,'cinereus.param'  ,
							'dictyostelium.param','dros.param'       ,'human.param'    ,'neurospora.param',
							'plasmodium.param'   ,'rice.param'       ,'tetraodon.param','wheat.param'     ,
							);
							
					%labels = (
							"arabidopsis.param" 	=> 'Aspergillus'   ,
							"aspergillus.param"  	=> 'Arabidopsis'   ,
							"celegans.param"      	=> 'Caenorhabditis',
							"cinereus.param"    	=> 'Coprinus'      ,
							"cneomorfans.param"	=> 'Cryptococcus'  ,
							"dictyostelium.param"	=> 'Dictyostelium' ,
							"dros.param"		=> 'Drosophila'    ,
							"human.param"		=> 'Human'		 ,
							"neurospora.param"	=> 'Neurospora'    ,
							"plasmodium.param"	=> 'Plasmodium'    ,
							"rice.param"		=> 'Rice'          ,
							"tetraodon.param"		=> 'Tetraodon'     ,
							"wheat.param"		=> 'Wheat'		 ,
				     	        );
				     print  $page->popup_menu(-name=>'prof',-values=>\@profile,-default=>'Neurospora',labels=>\%labels);
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
					print $page->submit(-name=>'action',-value=>'Procurar');
					print $page->submit(-name=>'action',-value=>'Limpar'   );
				print '</table>';
				print '</center>';
				print '</td>';
			print '</tr>';
		print '</table>';
	print $page->end_form();
	print '</center>';

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
