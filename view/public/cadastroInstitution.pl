#!/usr/bin/perl -d

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

#use warnings;
use CGI;
use Layout;
use controllerInstitution;
use SessionController;

# Instancing the modules Objects
my $page		= new CGI;
my $layout		= new Layout;
my $controller	= new controllerInstitution;
my $institution	= new Institution;

# Iniciang Tradution the page
print $page->header(-charset=>'utf-8');
print $page->start_html("Genome System Mining ");

# Using methods the Objects
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

# Declare variable scalar
	my $idInstitution  = '';
	my $nameInstitution= '';
	my $country        = '';
	my $state   	 = '';
	my $city    	 = '';
	my $operation	 = '';

# Take formularium's data
	if($page->param(action) && $page->param(institution) ne '')
	{
		$idInstitution	= $page->param('idInstitution');
		$nameInstitution	= $page->param('institution');
		$country		= $page->param('country');
		$state		= $page->param('state');
		$city			= $page->param('city');
		$operation		= $page->param('action');
	}
	elsif($page->param(idInstitution) && $page->param(action) eq '')
	{
		
		$idInstitution = $page->param(idInstitution);
		($idInstitution,$nameInstitution,$country,$state,$city) = $controller->selectInstitution($idInstitution);
	}
	elsif($page->param(action) eq 'Limpar')
	{
		print $page->redirect(-URL =>'cadastroInstitution.pl');
	}
	else
	{
		$idInstitution  = '';
		$nameInstitution= '';
		$country        = '';
		$state          = '';
		$city           = '';
		$operation      = '';
	}

# Header of Register
	print '<center><H2><br>';
		print 'Register Institution';
	print '</center></H2>';	

# Insert data on database
	if($operation)
	{
		my $result = $controller->cudInstitution($nameInstitution,$country,$state,$city,$operation,$idInstitution);
		print '<center> ', $result, ' </center>';	
		($nameInstitution,$country,$state,$city,$operation,$idInstitution) = '';
	}

# Form for crud institution
	print '<center> ';
	print $page->startform(-method=>'POST',-action=>'cadastroInstitution.pl',-name=>'registerInstitution');
	print '<fieldset>';
	print '<legend>Register Institution</legend>';
	print '<table>';

# institution Field
			print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					print $page->hidden(-name=>'idInstitution',-value=>$idInstitution,-size=>'65');
					print '<td>';
			print '</tr>';

# Institution Field
			print '<tr>';
				print '<td>';
					print 'Name  ';
					print '</td><td>';
					print $page->textfield(-name=>'institution',-value=>$nameInstitution,-size=>'65');
				print '</td>';
			print '</tr>';

# Email Field
			print '<tr>';
				print '<td>';
					print 'Country  ';
					print '</td><td>';
					print $page->textfield(-name=>'country',-value=>$country,-size=>'65');
				print '</td>';
			print '</tr>';

# Departament Field
			print '<tr>';
				print '<td>';
					print 'State  ';
					print '</td><td>';
					print $page->textfield(-name=>'state',-value=>$state,-size=>'65');
				print '</td>';
			print '</tr>';

# Departament Field
			print '<tr>';
				print '<td>';
					print 'City  ';
					print '</td><td>';
					print $page->textfield(-name=>'city',-value=>$city,-size=>'65');
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
					print $page->submit(-name=>'action',-value=>'Delete'  );
					print $page->submit(-name=>'action',-value=>'Limpar'   );
				print '</table>';
				print '</center>';
				print '</td>';
			print '</tr>';
		print '</table>';
		print '</fieldset>';
	print $page->end_form();
	print '</center> ';

	print '<center>';
	print '<table>';
	
# Form of search by institution    
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

#  Grid with data
	if($search ne '')
	{
		$result = $controller->selectAll($search);

		if ($result eq '')
		{
			print 'Unsuccessfully in the select!';
		}
		else
		{
			foreach $i (@$result)
			{
			
				print '<hr>';
				print @$i[1] . '  -  ' . @$i[2] , '<br>';
				print @$i[4] . '  -  ' . @$i[3] , '<br>';
				print "<a href=?idInstitution=@$i[0]>Editing Data</a>";
			}
		}
	}
	else
	{
		print '<center> <font color="green"> Search for Word!	   </font></center>';
		print '<center> <font color="green">Ex.: Phyto, Bio, Biology,</font></center>';
		
	}
	
# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
# Delete objeto
	$page->delete_all;
