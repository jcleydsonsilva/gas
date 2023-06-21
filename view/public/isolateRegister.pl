#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

use CGI;
use Layout;
use IsolatedController;

# Instancing the modules Objects
my $page	  = new CGI;
my $layout 	  = new Layout;
my $controller= new IsolatedController;

# Usando modulos
	print $page->header(-charset=>'utf-8');

# Using methods the Objects
	print $page->start_html("Genome System Mining ");
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
		print 'Register Isolate';
	print '</center></H2>';

# Take formularium's data
	if($page->param('action') && $page->param('specie') ne '')
	{
		$idIsolate      = $page->param('idIsolate');
		$isolateCode    = $page->param('isolateCode');
		$idLocality	    = $page->param('idLocality');
		$idUser         = $page->param('idUser');
		$specie         = $page->param('specie');
		$host           = $page->param('host');
		$collectionDate = $page->param('collectionData');
		$information    = $page->param('information');
		$state	    = $page->param('state');
		$city           = $page->param('city');
		$latitude       = $page->param('latitude');
		$longitude      = $page->param('longitude');
		$operation	    =	$page->param('action');
	}
	elsif($page->param('idIsolate') && $page->param('action') eq '')
	{
		my $id = $page->param('idIsolate');
		$isolated  = $controller->selectIsolate($id);

		foreach $i (@$isolated)
		{
				$idIsolate      = @$i[0];
				$isolateCode    = @$i[1];
			 	$idLocality	    = @$i[2];
				$idUser 	    = @$i[3];
				$specie         = @$i[4];
				$host           = @$i[5];
				$collectionDate = @$i[6];
				$information    = @$i[7];
				$idLocality	    = @$i[8];
				$state	    = @$i[9];
				$city           = @$i[10];
				$latitude       = @$i[11];
				$longitude      = @$i[12];
		}
	}
	elsif($page->param('action') eq 'Clear')
	{
		print $page->redirect(-URL =>'index.pl');
	}
	else
	{
		$result = 'Nada a fazer!';
	}

	if($page->param('action') eq 'Update')
	{
		$idIsolate      = $page->param('idIsolate');
		$isolateCode    = $page->param('isolateCode');
		$idLocality	    = $page->param('idLocality');
		$idUser         = $page->param('idUser');
		$specie         = $page->param('specie');
		$host           = $page->param('host');
		$collectionDate = $page->param('collectionData');
		$information    = $page->param('information');
		$state	    = $page->param('state');
		$city           = $page->param('city');
		$latitude       = $page->param('latitude');
		$longitude      = $page->param('longitude');
		$operation	    =	$page->param('action');  
	}

# Insert data on database
	if($operation)
	{
		my $result = $controller->dataInsert($idIsolate,$isolateCode,$idLocality,$idUser,$specie,$host,$collectionDate,$information,$state,$city,$latitude,$longitude,$operation,$session[3]);
		$session->header(-location=>"menssage.pl?msg=$result");
	}
	
# Form for crud institution
	print $page->start_form(-method=>'POST',-action=>'isolateRegister.pl',-name=>'isolateRegister');
	print '<table>';

# Isolate id Field
		print '<tr>';
			print '<td>';
				print '';
				print '</td><td>';
					print $page->hidden(-name=>'idIsolate', -value=>$idIsolate);
					print $page->hidden(-name=>'idLocality',-value=>$idLocality);
					print $page->hidden(-name=>'idUser',    -value=>$idUser);
				print '<td>';
		print '</tr>';

# Isolate Code Field
		print '<tr>';
			print '<td>';
				print 'Isolated code  ';
				print '</td><td>';
				print $page->textfield(-name=>'isolateCode',-value=>$isolateCode,-size=>'65');
			print '</td>';
		print '</tr>';

# Email Field
		print '<tr>';
			print '<td>';
				print 'Specie  ';
				print '</td><td>';
				print $page->textfield(-name=>'specie',-value=>$specie,-size=>'65');
			print '</td>';
		print '</tr>';

# Host Field
		print '<tr>';
		print '<td>';
			print 'Host  ';
			print '</td><td>';
			print $page->textfield(-name=>'host',-value=>$host,-size=>'65');
			print '</td>';
		print '</tr>';

# State Field
		print '<tr>';
		print '<td>';
			print 'State  ';
			print '</td><td>';
				print $page->textfield(-name=>'state', -value=>$state, -size=>'65');
		print '</td>';
		print '</tr>';

# City Field
		print '<tr>';
		print '<td>';
			print 'City  ';
			print '</td><td>';
				print $page->textfield(-name=>'city',-value=>$city, -size=>'65');
		print '</td>';
		print '</tr>';

# collection Date Field
		print '<tr>';
		print '<td>';
			print 'Date of collection:  ';
			print '</td><td>';
			print $page->textfield(-name=>'collectionData',-value=>$state,-size=>'65');
		print '</td>';
		print '</tr>';

# Geographic Coordiate
		print '<tr>';
		print '<td>';
			print 'Geographic Coordinate :  ';
			print '</td><td>';
			print "Latitude   ",$page->textfield(-name=>'latitude',-value=>$latitude,-size=>'23'),"Longitude  " ,$page->textfield(-name=>'longitude',-value=>$longitude,-size=>'23');
		print '</td>';
		print '</tr>';

# Add Information
		print '<tr>';
			print '<td>';
			print 'Informations  ';
			print '</td><td>';
				print $page->textarea(-name=>'information',-value=>$information,-rows=>7,-columns=>'62');
			print '</td>';
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
				print $page->submit(-name=>'action',-value=>'Update'  );
				print $page->submit(-name=>'action',-value=>'Deletar' );
				print $page->submit(-name=>'action',-value=>'Clear'  );
			print '</table>';
			print '</center>';
			print '</td>';
			print '</tr>';
		print '</table>';

# Form of search by isolated 

	print '<center>';
	print '<table>';
	print $page->startform(-method =>'POST',-action =>'',-name=>'Search');
		print '<br>';
		print '<tr>';
			print '<td>';
				print '';
			print '</td><td>';
			print $page->textfield(-name=>'Search',-value=>$search,-size=>'45');
				print $page->submit(-name=>'action',-value=>'Search');
			print '<td>';
		print '</tr>';
	print $page->end_form();
	print '</table>';
	print '</center>';

#  Grid with data

	if($page->param('Search') ne '')
	{
		$result = $controller->selectAll($search);
		if ($result eq '')
		{
			print 'Unable to select the institution!';
		}
		else
		{
			foreach $i (@$result)
			{
				print '<hr>';

				print @$i[1] . ' - ' . @$i[4],"<br>";
				print @$i[5],"<br>";
				print @$i[9] . ' - ' . @$i[10],"<br>";
				print @$i[11]. ' - ' . @$i[12], "<br>";
				print @$i[6],"<br>";
				print @$i[7],"<br>";

				print "<a href=?idIsolate=@$i[0]>Editing Data</a>\n";
				print "<a href=BuscaSimularidade.pl?idIsolate=@$i[0]>Similarity Search</a>";
			}
		}
	}
	else
	{
		print '<center><font color="green">Search for isolated</center>';
		print '<center> <font color="green">Ex.: GD0214, Microscylus, Micros, ulei </font></center>';
	}

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html;
	$page->delete_all();
