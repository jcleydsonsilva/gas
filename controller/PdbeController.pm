package PdbeController;

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
use Pdbe;

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

sub RunPDBE
{
	$idIsolate = shift;

	if(@_)
	{
		$idIsolate{idIsolate} = $_[0];
	}

	my $gene = "SELECT a.idaminoacids,a.identification,a.protein 
			FROM aminoacids a 
			INNER JOIN transcripty t On a.idtranscipty=t.idtranscripty 
			INNER JOIN sequence s 	 On t.idseq=s.idsequence 
			WHERE a.stage4 <> 'Ok' 
			AND s.idIsolate=$idIsolate
			AND length(a.protein) >=30
			ORDER BY a.identification";

	my $sth = $db->prepare($gene);

	if($sth->execute())
	{
		$protein = $sth->fetchall_arrayref();
	}

	foreach $i (@$protein)
	{
		# Gera um nome para cada arquivo com o para armazenar a output.
		$sequence	 = "@$i[2]\n";

		# Busca na base d edados PDBE
		@dados = ();
		@dados = Pdbe::SearchPdbe($sequence);

		foreach $d (@dados)
		{
			my $sql = "	INSERT INTO `structure3d` (idaminoacids,accessNumber,description,evalue)
					VALUES('@$i[0]','@$d[0]','@$d[1]','@$d[2]]')";

			# Prepara a execução da SQL
			my $sth = $db->prepare($sql);

			# Executa a SQL
			$sth->execute() or warn('Erro na inserção da busca!');
		}
		#########################################################
		# Atualiza o status da anotação do gene como ok
		#########################################################
		$update ="	UPDATE aminoacids SET stage4='Ok' WHERE idaminoacids='@$i[0]'";

		# Prepara a execução da SQL
		my $sth = $db->prepare($update);

		# Executa a SQL
		$sth->execute() or warn('Erro na inserção da validação da busca!');
	}
	return 'Abordagem no PDBe realizada com sucesso!';

}
return 1;
