#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Using in the system modules
use CGI;
use CGI::Session;
use Layout;
use BlastController;
use SessionController;

# Instancing the modules Objects
my $layout 	        = new Layout;
my $page   	        = new CGI;
my $session	        = new CGI::Session;
my $blastController = new BlastController;

# define path
my $filePath = '/var/www/gsm/files/in/';

# Usando modulos
print $page->header(-charset=>'utf-8');

# Take login in the session
	$username = $session->param('username'); 

# Using methods the Objects
print $page->start_html(" Mu Blast ");
	print $layout->header();

	use CGI::Session;
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

# Take formularium's data
	if($page->param('action'))
	{
		$database  = $page->param('database');
		$program   = $page->param('program');
		$operation = $page->param('action');
		$filename  = $page->upload('file');

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
			close(OUTFILE);
		}
		else
		{
			$filename = 'false';
		}
	
		$blastController->RunBlast($database,$program,$filename,$operation);
	}
	else
	{
		$result = 'Nada a fazer!';
	}

		print '<center><H2><br>';
			print 'BLAST in the genome';
		print '</center></H2>';
# Form for crud institution
		print $page->start_form(-method=>'POST',-action=>'muBlast.pl',-name=>'muBlast');
		print '<br><br>';
		print '<fieldset>';
		print '<legend>Mu Blast</legend>';
		print '<table>';
# Database Field
			print '<tr>';
				print '<td>';
					print 'Database  ';
					print '</td><td>';
					@database = ('Microcyclus-Genome','Microcyclus-Trasncripty','Microcyclus-Gene','Mycosphaerellaceae','Nr-aa/nt','NCBI');
					@program = ('blastn','blastp','blastx','tblastx');
					print $page->popup_menu(-name=>'database', -values=>\@database),"Program  ", $page->popup_menu(-name=>'program', -values=>\@program);
				print '</td>';
			print '<br>';	
			print '</tr>';

# Input File FASTA Field
			print '<tr>';
				print '<td>';
					print 'FASTA file';
					print '</td><td>';
				    print $page->filefield(-name=>'file', -size=>55);
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
					print $page->submit(-name=>'action',-value=>'Search');
					print $page->submit(-name=>'action',-value=>'Clear'   );
				print '</table>';
				print '</center>';
				print '</td>';
			print '</tr>';
		print '</table>';
	print '</fieldset>';
	print $page->end_form();

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
