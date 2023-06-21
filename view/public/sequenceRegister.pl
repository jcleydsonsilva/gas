#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI;
use CGI::Session;
use Layout;
use IsolatedController;
use SequenceController;
use SessionController;

# Instancing the modules Objects
my $layout		= new Layout;
my $controller	= new IsolatedController;
my $seqController	= new SequenceController;
my $page		= new CGI;
my $session		= new CGI::Session;

# define path
 my $filePath = '/var/www/gsm/files/';

# Usando modulos
print $page->header(-charset=>'utf-8');

# Take login in the session
	$username = $session->param('email'); 

# Using methods the Objects
	print $page->start_html("Genome System Mining ");
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

# Header of cadaster
	print '<center><H2><br>';
		print 'Register Sequence';
	print '</center></H2>';

# Take formularium's data
	
	if($page->param('action'))
	{
		$idIsolate  = $page->param('idIsolate');
		$type		= $page->param('type');
		$isolateCode= $page->param('isolateCode');
		$operation	= $page->param('action');
		
		$filename  	= $page->upload('file');

		# undef may be returned if it's not a valid file handle
		if (defined $filename)
		{
			# Upgrade the handle to one compatible with IO::Handle:
			my $io_handle = $filename->handle;
			
			open (OUTFILE,'>>',$filePath.$filename);
			while ($bytesread = $io_handle->read($buffer,1024000))
			{
		 		print OUTFILE $buffer;
			}
		}
		else
		{
			$filename = 'false';
		}
	}
	elsif($page->param('idIsolate') && $page->param('action') eq '')
	{
		
		my $id     = $page->param('idIsolate');
		$isolated  = $seqController->selectIsolate($id);
		
		foreach $i (@$isolated)
		{
			$idIsolate 	= @$i[0];
			$isolateCode= @$i[1];
		}
			
	}
	elsif($page->param('action') eq 'Clear')
	{
		print $page->redirect(-URL =>'sequenceRegister.pl');
	}
	elsif($page->param('msg') ne '')
	{
		$msg = $page->param('msg');
	}
	else
	{
		$result = 'Nada a fazer!';
	}

# Insert data on database
	if($operation eq 'Register')
	{
		my $result = $seqController->seqInsert($idIsolate,$type,$isolateCode,$filename,$operation);
		$session->header(-location=>"menssage.pl?msg=$result");
	}

# Form of search by isolated
	print '<center>';
	print '<table>';
	$search = $page->param('search');
	print $page->startform(-method =>'POST',-action =>'',-name=>'search');
		print '<br>';
		print '<tr>';
			print '<td>';
			print '';
			print '</td><td>';
			print $page->textfield(-name=>'search',-value=>$search,-size=>'45');
			print $page->submit(-name=>'action',-value=>'Search');
			print '<td>';
		print '</tr>';
	print $page->end_form();
	print '</table>';
	print '</center>';

	print '<center> <font color="green"> Search for isolated</center> </font>';
	print '<center> <font color="green">Ex.: GD0214, Microscylus, Micros, ulei </font></center>';
# Form for crud institution
	print $page->start_form(-method=>'POST',-action=>'sequenceRegister.pl',-name=>'sequenceRegister');
	
		print '<fieldset>';
		print '<legend>Register Sequence</legend>';
		print '<table>';

# Sequence id Field
			print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					print $page->hidden(-name=>'idSequence', -value=>$idSequence);
					print $page->hidden(-name=>'idIsolate' , -value=>$idIsolate);
					print '<td>';
			print '</tr>';

# Isolate Code Field
			print '<tr>';
				print '<td>';
					print 'Sequence Type';
					print '</td><td>';
					@type = (Read,Contig,Scafold,Fragment);
					print $page->popup_menu(-name=>'type', -values=>\@type);
				print '</td>';
			print '<br>';
			print '</tr>';

# Isolate Code Field
			print '<tr>';
				print '<td>';
					print 'Isolate ';
					print '</td><td>';
					print $page->textfield(-name=>'isolateCode',-value=>$isolateCode,-size=>'65');
				print '</td>';
			print '<br>';
			print '</tr>';
			
# Input File FASTA Field
			print '<tr>';
				print '<td>';
					print 'FASTA File';
					print '</td><td>';
					print $page->filefield(-name=>'file',-size=>55);
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
					print $page->submit(-name=>'action',-value=>'Register');
					print $page->submit(-name=>'action',-value=>'Clear'   );
				print '</table>';
				print '</center>';
				print '</td>';
			print '</tr>';
		print '</table>';
	print '</fieldset>';
	print $page->end_form();

#  Grid with data
	if($search ne '')
	{

		$result = $controller->selectAll($search);

		if ($result eq '')
		{
			print 'Não foi possível selecionar a isolado!';
		}
		else
		{
			foreach $i (@$result)
			{
				print '<hr>';
				print @$i[1] . ' - ' . @$i[4],"<br>";
				print @$i[5],"<br>";
				print @$i[9] . ' - ' . @$i[10],"<br>";
				print "<a href=?idIsolate=@$i[0]>Sequence insert</a>";
			}
		}
	}

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
# Delete objeto
	$page->delete_all;
