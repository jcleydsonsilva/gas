#!/usr/bin/perl -w

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

#use strict;
use CGI;
use Layout;
use userController;

# Instancing the modules Objects
my $page	  = new CGI;
my $layout	  = new Layout;

# Iniciang Tradution the page
print $page->header(-charset=>'utf-8');
print $page->start_html("Genome System Mining ");

# Using methods the Objects
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
	if($page->param('operation') && $page->param('name') ne '')
	{
		$iduser	=$page->param('iduser');
		$user		=$page->param('name');
		$email	=$page->param('email');
		$institution=$page->param('institution');
		$department	=$page->param('department');
		$laboratory	=$page->param('laboratory');
		$adviser	=$page->param('adviser');
		$level	=$page->param('level');
		$password	=$page->param('password');
		$operation	=$page->param('operation');
	}
	elsif($page->param('iduser') ne '' && $page->param('query') eq '' && $page->param('result') eq '')
	{
		$iduser=$page->param('iduser');
		@dados =();
		@dados = userController::selectUser($iduser);
	}
	else
	{
		@dados =();
	}

# Header of cadaster
	print '<center><H2><br>';
		print 'Register user';
	print '</center></H2>';

# Insert data on database
	if($operation ne '' && $page->param('search') eq '')
	{
		my $result = userController::userCrud($iduser,$user,$email,$institution,$department,$laboratory,$adviser,$level,$password,$operation);
		$session->header(-location=>"menssage.pl?msg=$result");
	}

# Form for crud institution
	print $page->startform(-method=>'POST',-operation=>'',-name=>'userRegister');
	print '<table>';

# User Field
			print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					print $page->hidden(-name=>'iduser',-value=>$dados[0],-size=>'65');
   					print '<td>';
			print '</tr>';
# user Field
			print '<tr>';
				print '<td>';
					print 'Name  ';
					print '</td><td>';
					print $page->textfield(-name=>'name',-value=>$dados[1],-size=>'65');
				print  '</td>';
			print '</tr>';

# Email Field

			print '<tr>';
				print '<td>';
					print 'Email  ';
					print '</td><td>';
					print $page->textfield(-name=>'email',-value=>$dados[2],-size=>'65');
				print '</td>';
			print '</tr>';

# Text Field
			print '<tr>';
				print '<td>';
					print 'Institution  ';
					print '</td><td>';
					print $page->textfield(-name=>'institution',-value=>$dados[3],-size=>'65');
				print '</td>';
			print '</tr>';

# Adviser Field
			print '<tr>';
				print '<td>';
					print 'Adviser  ';
					print '</td><td>';
					print $page->textfield(-name=>'adviser',-value=>$dados[4],-size=>'65');
				print '</td>';
			print '</tr>';
			

# Department Field
			print '<tr>';
				print '<td>';
					print 'Departament';
					print '</td><td>';
					print $page->textfield(-name=>'department',-value=>$dados[5],-size=>'65');
				print '</td>';
			print '</tr>';

# Laboratory Field
			print '<tr>';
				print '<td>';
					print 'Laboratory  ';
					print '</td><td>';
					print $page->textfield(-name=>'laboratory',-value=>$dados[6],-size=>'65');
				print '</td>';
			print '</tr>';

# Level Field
			print '<tr>';
				print '<td>';
					print 'Level  ';
					print '</td><td>';
					print $page->textfield(-name=>'level',-value=>$dados[7],-size=>'1');
					print "\t0- Administrator 1- Anotator 2- Common User";
				print '</td>';
			print '</tr>';

# Password Field
			print '<tr>';
				print '<td>';
					print 'Password  ';
					print '</td><td>';
					print $page->password_field(-name=>'password',-value=>$dados[8],-size=>'25');
				print '</td>';
			print '</tr>';
			
# operation button
			print '<tr>';
			print '<br>';
				print '<td>';
					print '    ';
				print '</td>';
				print '<td>';
				print '<center>';
				print '<table>';
				print '<br>';
					print $page->submit(-name=>'operation',-value=>'Register')."\t";
					print $page->submit(-name=>'operation',-value=>'Update')."\t";
					print $page->submit(-name=>'operation',-value=>'Delete'  )."\t";
					print $page->reset (-name=>'operation',-value=>'Clear'   );
				print '</table>';
				print '</center>';
				print '</td>';
			print '</tr>';
		print '</table>';
	print $page->end_form();

	print '<center>';
	print '<table>';
	
# Form of search by institution    
	print $page->startform(-method =>'POST',-operation =>'',-name=>'search');
			print '<br>';
			print '<tr>';
				print '<td>';
					print '';
					print '</td><td>';
					print $page->textfield(-name=>'search',-value=>$search,-size=>'45');
					print $page->submit(-name=>'query',-value=>'Search');
				print '<td>';
			print '</tr>';
	print $page->end_form();
	print '</table>';
	print '</center>';

#  Grid with data
	$search = $page->param('search');
	if($search ne '')
	{
		$result = userController::selectAll($search);

		if ($result eq '')
		{
			print 'Não foi possível selecionar a usuario!';
		}
		else
		{
			foreach $i (@$result)
			{
				print '<hr>';
				print @$i[1], '  -  ', @$i[2],'<br>';
				print @$i[4], '  -  ', @$i[5],'<br>';
				print @$i[6], '<br>';
				print "<a href=?iduser=@$i[0]>Edit</a>";
			}
		}
	}
	else
	{
		print '<center><font color="green"> Do to search by name!!</font></center>';
		print '<center> <font color="green">Ex.: Joa, Jos, Joao, Jose </font></center>';
	}

# Show rodapé
	print $layout->lower();

# Finalize page
	print $page->end_html();
# Delete objeto
	$page->delete_all;
