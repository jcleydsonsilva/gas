package FamilyGoController;

####################################################################################
# Classe 
# 
# 
# Autor:
# José Cleydson Ferreira da Silva - 13/12/11
#####################################################################################

#####################################################################################
# Bibliotecas e classes modelos utilizadas no sistema
#####################################################################################
use lib '/var/www/gsm/model/';

use Connect;
use InterProScan;
use Data::Dumper;

#####################################################################################
# Objeto de conexão com a base de dados
#####################################################################################
	$db = Connect::db;

#####################################################################################
# Monta a base de dados não redunante a partir do numero do isolado. Utilizados vários
# criterios para a montagem:
# 1 - 
# 2 - 
# 3 -
# 4 - 
#####################################################################################

sub RunFamilyGo
{
	$idIsolate = shift;

	if(@_)
	{
		$idIsolate{idIsolate} = $_;
	}

	my $gene = "SELECT a.idaminoacids,a.identification,a.protein 
			FROM aminoacids a 
			INNER JOIN transcripty t On a.idtranscipty=t.idtranscripty 
			INNER JOIN sequence s 	 On t.idseq=s.idsequence 
			WHERE a.stage2 <> 'Ok'
			AND length(a.protein) >=30
			AND s.idIsolate=$idIsolate
			ORDER BY a.identification";

	my $sth = $db->prepare($gene);

	if($sth->execute())
	{
		$protein = $sth->fetchall_arrayref();
	}

	foreach $i (@$protein)
	{
		# Gera um nome para cada arquivo com o para armazenar a output.
		$sequence	 = "@$i[1]\n@$i[2]\n";
		$namefile	 = 'interpro';
		$namefile 	.= localtime(time);
		$namefile	=~ s/[[:blank:]]+//g;
		$namefile	.= '.txt';
		$output = "/var/www/gsm/files/out/$namefile";

		#Executa o processo de busca no interproscan
		$status = InterProScan::RunInterProScan($sequence,$output);

		if($status eq 'Ok')
		{
			# Inicia o processo de Text-Mining para apuração dos resultados
			InterProScan::ParserInterProScan($output,@$i[0]);
		}
		else
		{
			print "@$i[0] - Não encontrou nada!\n";
		}
		#########################################################
		# Atualiza o status da anotação do gene como ok
		#########################################################
		$update ="UPDATE aminoacids
			    SET stage2='Ok' WHERE idaminoacids='@$i[0]'";

		# Prepara a execução da SQL
		my $sth = $db->prepare($update);
		
		# Executa a SQL
		$sth->execute() or warn('Erro na inserção da validação da busca!');
	}
	return 'Abordagem no Interpro realizada com sucesso!';
}

return 1
