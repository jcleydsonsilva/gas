#!/usr/bin/perl

package RemBlast;

# Blast Remoto
use Bio::Tools::Run::RemoteBlast;
use Bio::SearchIO; 

sub QueryBlast
{
	my $e_val= '1e-10';
	my $filename = shift;
	my $output	 = shift;
	my $prog	 = shift;
	my $db	 = shift;
	my $organismo= shift;
	my $exclude  = shift;

	if(@_)
	{
		$filename	{filename }	= $_[0];
		$output	{output   }	= $_[1];
		$prog		{prog     }	= $_[2];
		$db		{db       }	= $_[3];
		$organismo	{organismo}	= $_[4];
		$exclude    {exclude  }	= $_[5];
	}
	# parâmetros para análise
	my @params =('-prog'	  =>$prog,
			 '-data'	  =>$db,
			 '-expect'	  =>$e_val,
			 '-readmethod'=>'SearchIO'
			);

	my $factory = Bio::Tools::Run::RemoteBlast->new(@params);

	#change a query parameter
	$Bio::Tools::Run::RemoteBlast::HEADER{'ENTREZ_QUERY'} = "$organismo [ORGN]";

	#change a retrieval parameter
	$Bio::Tools::Run::RemoteBlast::RETRIEVALHEADER{'DESCRIPTIONS'} = 1000;

	#remove a parameter
	delete $Bio::Tools::Run::RemoteBlast::HEADER{'FILTER'};

	#$v is just to turn on and off the messages
	my $v = 1;

	my $str = Bio::SeqIO->new(-file=>$filename,-format => 'fasta' );

	while (my $input = $str->next_seq())
	{
		#Alternatively, you couldpass in a file with many
		#sequences rather than loop through sequence one at a time
		#Remove the loop starting 'while (my $input = $str->next_seq())'
		#and swap the two lines below for an example of that.
		my $r = $factory->submit_blast($input);
		#my $r = $factory->submit_blast('amino.fa');

		#print STDERR "waiting..." if( $v > 0 );
		while ( my @rids = $factory->each_rid )
		{
			foreach my $rid ( @rids )
			{
				my $rc = $factory->retrieve_blast($rid);
				if( !ref($rc) )
				{
					if( $rc < 0 )
					{
						$factory->remove_rid($rid);
					}
				}
				else 
				{
					my $result = $rc->next_result();
					#save the output
					$factory->save_output($output);
					$factory->remove_rid($rid);
				}
			}
		}
	}
	# Limpa o array na primeira vez que a função é chamada
	@homology = ();

	# Faz a entrado do arquivo com resultado
	my $in = new Bio::SearchIO(	-format => 'blast',
						-file   => $output
						);
	# Busca cada resultado
	while( my $result = $in->next_result )
	{
		# Pega cada hit e seus respctivos valores
		while( my $hit = $result->next_hit )
		{
			# Pega o valor de cada hit
			$accession	= $hit->accession	  ;
			$description= $hit->description ;
			$score 	= $hit->bits	  ;
			$evalue	= $hit->significance;

			# Limpa o array
			@hits = ();

			# Monta um array com os resultados
			@hits = ($accession,$description,$score,$evalue);
			push @homology,[@hits];
		}
	}

	# Remove os arquivos
	system "rm $filename";
	system "rm $output"  ;

	# Retorna os genes homologos encontrados
	return @homology;
}
return 1;
