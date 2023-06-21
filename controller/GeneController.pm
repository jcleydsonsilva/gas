########################################################################
# Classe de controller da tela de anotação de genes
# 
# Autor: SILVA, JCF
# Data 22/11/2011
# Versão 1.0
########################################################################
package GeneController;

########################################################################
# Módulos utilizados pela classe controller GeneController
########################################################################
	use lib '/var/www/gsm/model/';
	use Connect;
	use Bio::Seq;

########################################################################
# Objeto de conexão com a base de dados
########################################################################
	$db = Connect::db;

#########################################################################
# 
#########################################################################
sub SearchEngine
{
	my $query = shift;
	if(@_)
	{
		$query{query} = $_[0];
	}
	my $gene = "SELECT DISTINCT b.idaminoacids,a.identification,b.accessNumber,b.description,p.descricao FROM aminoacids a 
			INNER JOIN proteinFamily p ON a.idaminoacids=p.id_aminoacids 
			INNER JOIN bestHit b ON b.idaminoacids=p.id_aminoacids 
			INNER JOIN geneOntology g ON a.idaminoacids=g.id_aminoacids
			INNER JOIN entryKeeg k ON a.idaminoacids=k.idaminoacids
			INNER JOIN orthology o ON k.idaminoacids=o.identryKeeg
			INNER JOIN pathway pt ON k.identryKeeg=pt.identryKeeg
			WHERE b.accessNumber	like '$query%' 
			OR b.description		like '$query%' 
			OR p.numacesso		like '$query%' 
			OR p.descricao		like '$query%'
			OR p.numInterpro		like '$query%'
			OR p.descricaoInterpro	like '$query%'
			OR g.descricao		like '$query%'
			OR g.numGo			like '$query%'
			OR k.accessNumber		like '$query%'
			OR k.description		like '$query%'
			OR o.accessNumber		like '$query%'
			OR o.description		like '$query%'
			OR o.enzyme			like '$query%'
			OR pt.accessNumber	like '$query%'
			OR pt.description		like '$query%'";


	# Preparação e execução de da sql
	my $sth = $db->prepare($gene);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$descricoes = $sth->fetchall_arrayref();
		return $descricoes;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}

sub DescGene
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}

	my $indent = "SELECT s.seqIdenticator,t.program,t.numbergene 
			FROM sequence s 
			INNER JOIN transcripty t ON s.idsequence=t.idseq 
			INNER JOIN aminoacids a ON t.idtranscripty=a.idtranscipty 
			WHERE idaminoacids='$idaminoacids'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($indent);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$descOneGene = $sth->fetchall_arrayref;
		return $descOneGene;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}


sub AllExon
{
	my $idaminoacids = shift;
	my $program	  = shift;
	my $numGene	  = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids}	= $_[0];
		$program	 {program}		= $_[0];
		$numGene	 {numGene}		= $_[0];
	}
	
	my $exon = "SELECT g.region,g.chain,g.start,g.stop 
		   FROM gene g 
		   INNER JOIN sequence s ON g.idseq=s.idsequence 
		   INNER JOIN transcripty t ON s.idsequence=t.idseq 
		   INNER JOIN aminoacids a ON t.idtranscripty=a.idtranscipty 
		   WHERE idaminoacids='$idaminoacids' 
		   AND g.program='$program' 
		   AND g.numGene='$numGene'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($exon);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$exons = $sth->fetchall_arrayref;
		return $exons;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}

sub AllGenes
{
	my $accessNumber = shift;

	if(@_)
	{
		$accessNumber{accessNumber} = $_[0];
	}

	my $other = "SELECT DISTINCT a.idaminoacids,a.identification 
			FROM aminoacids a 
			INNER JOIN bestHit b ON a.idaminoacids=b.idaminoacids 
			WHERE b.accessNumber='$accessNumber'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($other);

	# Executa a SQL
	if($sth->execute())
	{
		# Pega todos os ids das sequencias selecionadas
		$other = $sth->fetchall_arrayref;
		return $other;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}

sub BestHit
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}

	my $gen = "SELECT DISTINCT idaminoacids,accessNumber,description,score,evalue,bank FROM bestHit 
			WHERE idaminoacids='$idaminoacids'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($gen);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$bestHit = $sth->fetchall_arrayref();
		return $bestHit;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}

sub ProteinFamily
{
	$idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}

	my $gen = "SELECT DISTINCT idproteinFamily,id_aminoacids,metodo,numacesso,descricao,numInterpro,descricaoInterpro 
			FROM proteinFamily 
			WHERE id_aminoacids=$idaminoacids";

	# Preparação e execução de da sql
	my $sth = $db->prepare($gen);
	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$proteinFamily = $sth->fetchall_arrayref();
		return $proteinFamily;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}

sub GeneOntology
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}

	my $gen = "SELECT DISTINCT id_aminoacids,functionOntology,descricao,numGo
			FROM geneOntology 
			WHERE id_aminoacids=$idaminoacids";

	# Preparação e execução de da sql
	my $sth = $db->prepare($gen);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$geneOntology = $sth->fetchall_arrayref();
		return $geneOntology;
	}
	else
	{
		return 'Não foi possível selecionar os genes!';
	}
}

sub KeegProtein
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}
	
	my $protein = "SELECT e.accessNumber,e.description
			FROM entryKeeg e 
			WHERE e.idaminoacids='$idaminoacids'";

		# Preparação e execução de da sql
	my $sth = $db->prepare($protein);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$protein = $sth->fetchall_arrayref();
		return $protein;
	}
}

sub KeegOrtho
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}
	
	my $ortho = "SELECT o.accessNumber,o.description,o.enzyme
			FROM orthology o
			INNER JOIN entryKeeg e ON o.identryKeeg=e.identryKeeg
			WHERE e.idaminoacids='$idaminoacids'";

		# Preparação e execução de da sql
	my $sth = $db->prepare($ortho);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$ortho = $sth->fetchall_arrayref();
		return $ortho;
	}
}

sub KeegPathway
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}
	
	my $path = "SELECT p.accessNumber,p.description
			FROM pathway p
			INNER JOIN entryKeeg e ON p.identryKeeg=e.identryKeeg
			WHERE e.idaminoacids='$idaminoacids'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($path);

	# Executa a SQL
	if($sth->execute())
	{	
		# Pega todos os ids das sequencias selecionadas
		$path = $sth->fetchall_arrayref();
		return $path;
	}
}

sub GetTransAmi
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}
	
	my $transAmino = "SELECT a.protein,t.gene FROM transcripty t 
				INNER JOIN aminoacids a ON t.idtranscripty=a.idtranscipty 
				WHERE a.idaminoacids='$idaminoacids'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($transAmino);

	# Executa a SQL
	if($sth->execute())
	{
		# Pega todos os ids das sequencias selecionadas
		my @transAmino = $sth->fetchrow_array();
		return @transAmino;
	}
}

sub GetStructure
{
	my $idaminoacids = shift;
	if(@_)
	{
		$idaminoacids{idaminoacids} = $_[0];
	}
	
	my $structure = "SELECT accessNumber,description,evalue
				FROM structure3d 
				WHERE idaminoacids='$idaminoacids' ORDER BY evalue;";

	# Preparação e execução de da sql
	my $sth = $db->prepare($structure);

	# Executa a SQL
	if($sth->execute())
	{
		# Pega todos os ids das sequencias selecionadas
		my $structure = $sth->fetchall_arrayref();
		return $structure;
	}
}

sub GetExonIntron
{
	my $inicio_gene = shift;
	my $fim_gene    = shift;
	my $idaminoacids= shift;
	my $chain	    = shift;

	if(@_)
	{
		$inicio_gene{inicio_gene}  = $_[0];
		$fim_gene{fim_gene}        = $_[1];
		$idaminoacids{idaminoacids}= $_[2];
		$chain{chain}		   = $_[3];
	}

	my $exonwithintron = "SELECT s.sequence FROM sequence s 
				INNER JOIN transcripty t ON s.idsequence=t.idseq 
				INNER JOIN aminoacids a ON t.idtranscripty=a.idtranscipty 
				WHERE a.idaminoacids='$idaminoacids'";

	# Preparação e execução de da sql
	my $sth = $db->prepare($exonwithintron);

	# Executa a SQL
	if($sth->execute())
	{
		# Pega todos os ids das sequencias selecionadas
		my @exonwithintron = $sth->fetchrow_array();

		my $inicio = $inicio_gene-200;
		my $fim    = $fim_gene+200;
		my $tamanho= ($fim-$inicio);
		$exonwithintron   = substr($exonwithintron[0],$inicio,$tamanho);

		if($chain eq 'Reverse')
		{
			my $seq = Bio::Seq->new(-seq => $exonwithintron);
			$exonwithintron = $seq->revcom->seq();
			return $exonwithintron;
		}
		else
		{
			return $exonwithintron;
		}
	}
}
return 1
