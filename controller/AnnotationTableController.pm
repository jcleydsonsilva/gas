package AnnotationTableController;

########################################################################
# Classe de controller da tela de anotação de genes

# Autor: SILVA, JCF
# Data 22/11/2011
# Versão 1.0
########################################################################


########################################################################
# Módulos utilizados pela classe controller AnotationController
########################################################################
	use lib '/var/www/gsm/model/';
	use Connect;

########################################################################
# Objeto de conexão com a base de dados
########################################################################
	$db = Connect::db;

########################################################################
# Pega a estimativa de anotação de cada programa 
########################################################################
sub getEstProgram
{
	my $idiso = shift;

	if(@_)
	{
		$idiso{idiso} = $_[0];
	}
	#SQL para buscar os transcritos de um gene
	my $sql = "SELECT DISTINCT program FROM transcripty";

	# Preparação e execução da SQL
	my $sth = $db->prepare($sql);
	if($sth->execute())
	{
		# Seleciona todos os programas que 
		$program = $sth->fetchall_arrayref();
	}

	@total = ();
	foreach $i (@$program)
	{
		#####################################################################
		# Seleciona o total de genes por programa
		#####################################################################
		my $total = "SELECT COUNT(*) FROM transcripty t
				INNER JOIN sequence s ON t.idseq=s.idsequence
				WHERE s.idIsolate='$idiso' AND t.program='@$i[0]' AND length(t.gene) >= 90";
		
		#print $total;
		#exit;
		# Preparação e execução da SQL
		my $sth = $db->prepare($total);
		if($sth->execute())
		{
			# Busca o total de genes por programa
			@array = ();
			@array = $sth->fetchrow_array;
		}

		#####################################################################
		# Seleciona o total de genes que não possuem similaridade nohis
		#####################################################################
		my $totalnohits = "SELECT COUNT(*) FROM transcripty t 
					INNER JOIN aminoacids a ON t.idtranscripty=a.idtranscipty 
					INNER JOIN noHit n ON a.idaminoacids=n.id_aminoacids
					INNER JOIN sequence s ON t.idseq=s.idsequence
					WHERE s.idIsolate='$idiso' AND t.program='@$i[0]'";

		# Preparação e execução da SQL
		my $sth = $db->prepare($totalnohits);
		if($sth->execute())
		{
			# Busca o total de genes por programa
			@noHit = ();
			@noHit = $sth->fetchrow_array;
		}

		#####################################################################
		# Seleciona o total de genes que já foram pré anotados
		#####################################################################
		my $preannotation = "SELECT COUNT(*) FROM transcripty t 
					INNER JOIN aminoacids a ON t.idtranscripty=a.idtranscipty 
					INNER JOIN sequence s ON t.idseq=s.idsequence
					WHERE s.idIsolate='$idiso' AND t.program='@$i[0]' AND a.stage1='Ok'";

		# Preparação e execução da SQL
		my $sth = $db->prepare($preannotation);
		if($sth->execute())
		{
			# Busca o total de genes por programa
			@preannotation = ();
			@preannotation = $sth->fetchrow_array;
		}

		#################################################################################################
		# Monta o conjunto de dados, com Programa -> total gene -> noHits
		#################################################################################################
		@linha = ();
		@linha = (@$i[0],$array[0],$preannotation[0],@noHit[0]);
		push @total,[@linha];
	}

	return @total;
}

sub getSpecie
{
	my $specie = "SELECT idisolatedSample,codeIsolated,specie FROM isolatedSample";
	# Preparação e execução da SQL
	my $sth = $db->prepare($specie);
	if($sth->execute())
	{
		# Seleciona todos os programas que 
		$specie = $sth->fetchall_arrayref();
	}
	return $specie;
}

sub getInfo
{
	# Why Information?
}
	$rc = $db->disconnect;
return 1;
