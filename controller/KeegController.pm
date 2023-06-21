package KeegController;

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
use Keeg;

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

sub RunKeeg
{
	$idIsolate = shift;

	if(@_)
	{
		$idIsolate{idIsolKeegate} = $_[0];
	}

	my $gene = "SELECT a.idaminoacids,a.identification,a.protein 
			FROM aminoacids a 
			INNER JOIN transcripty t On a.idtranscipty=t.idtranscripty 
			INNER JOIN sequence s 	 On t.idseq=s.idsequence 
			WHERE a.stage3 <> 'Ok' 
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
		$sequence	 = "@$i[1]\n@$i[2]\n";
		$namefile	 = 'keeg';
		$namefile 	.= localtime(time);
		$namefile	=~ s/[[:blank:]]+//g;
		$namefile	.= '.txt';
		$output = "/var/www/gsm/files/out/$namefile";

		#Executa o processo de busca no interproscan
		@hitKeeg = ();
		@hitKeeg = Keeg::SearchKeeg($sequence,$output,'BestHit');

		if($hitKeeg[0] ne '')
		{
			$namefile = 'Ko';
			$namefile .= localtime(time);
			$namefile =~ s/[[:blank:]]+//g;
			$namefile .= '.html';
			$output = "/var/www/gsm/files/out/$namefile";

			# Inicia o processo de Text-Mining para apuração dos resultados
			Keeg::SetInformation($hitKeeg[0],$output);

			# Pega o número de acesso da Ortologia
			@ortho = ();
			@ortho = Keeg::GetOrthology();

			# Pega o número de acesso das Enzimas
			$enzyme = '';
			$enzyme = Keeg::GetEnzyme();

			# Pega o número de acesso das vias Metabólicas
			@pathways = ();
			@pathways = Keeg::GetPathways();

			# Insere os dados referente ao Entry KEEG
			my $entryKeeg = "INSERT INTO entryKeeg (idaminoacids,accessNumber,description)
						VALUES('@$i[0]','$hitKeeg[0]','$hitKeeg[1]')";

			my $sth = $db->prepare($entryKeeg);

			$sth->execute() or warn ("Erro ao inserir na tabela entryKeeg ");

			# Pega o ultimo id inserido na tabela entryKeeg
			my $id = "SELECT LAST_INSERT_ID() as id";
			# 2
			my $sth = $db->prepare($id);
			$sth->execute;
			@id = $sth->fetchrow_array;

			# Insere dados referentes a Orthology
			if($ortho[0] ne '')
			{
				my $orthology = "INSERT INTO orthology (identryKeeg,accessNumber,description,enzyme)
							VALUES('$id[0]','$ortho[0]','$ortho[1]','$enzyme')";

				my $sth = $db->prepare($orthology);
				$sth->execute() or warn ("Erro ao inserir na tabela orthology ");
			}

			# Insere dados referentes a Pathways
			$tampath = @pathways;
			if($tampath>0)
			{

				foreach $p (@pathways)
				{
					if(@$p[0] ne '')
					{
						if(@$p[1] !~ /CDS/)
						{
							my $path = "INSERT INTO pathway (identryKeeg,accessNumber,description)
								VALUES('$id[0]','@$p[0]','@$p[1]')";

							my $sth = $db->prepare($path);

							$sth->execute() or warn ("Erro ao inserir na tabela orthology ");
						}
					}
				}
			}
		}

		#########################################################
		# Atualiza o status da anotação do gene como ok
		#########################################################
		$update ="	UPDATE aminoacids
		SET stage3='Ok' WHERE idaminoacids='@$i[0]'";

		# Prepara a execução da SQL
		my $sth = $db->prepare($update);

		# Executa a SQL
		$sth->execute() or warn('Erro na inserção da validação da busca!');
	}
	return 'Abordagem no KEEG realizada com sucesso!';

}

return 1
