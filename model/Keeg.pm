package Keeg;


# Módulo utilizado para fazer a consulta on-line
use WWW::Mechanize;
use feature qw/ say /;
use HTML::TreeBuilder::XPath;

sub SearchKeeg
{
	my $sequence= shift;
	my $output	= shift;
	my $flag	= shift;

	if(@_)
	{
		$sequence{sequence} = $_[0];
		$output  {output  } = $_[1];
	}
	my $mech = WWW::Mechanize->new();

	$mech->get('http://www.genome.jp/tools/blast/');

	$mech->submit_form
				(
				fields => {
						'sequence'	  => "$sequence", 
						'prog'   	  => 'blastp',
						'myspecies-aa'=> 'Ascomycetes',
						}
				);

	# Salva os dados em um arquivo
	open (OUT, ">>$output");
		print OUT $mech->content();
	close(OUT);

	# Abre o arquivo para leitura dos dados
	open(INFILE,"<$output");
		@keegArray = ();
		@BestHit;
		$i=0;
		while($line = <INFILE>)
		{
			if($line =~ /<a href="/)
			{
				if($line =~ /Show all result/ or $line =~ /integrated database retrieval system/)
				{}
				else
				{
					# Quebra a linha
					@lines = split(/<a/,$line);
					# Fomata o texto no padrão numero - descrição
					@temp 	= split (/>/,$lines[1]);
					$description= $temp[2];
					$number	= $temp[1];
					$number	=~ s/<\/a//g;
					# Monta o array com os dados
					@keegOne	= ();
					if($i<1)
					{
						@BestHit = ($number,$description);
					}
					@keegOne	= ($number,$description);
					push @keegArray, [@keegOne];
				}
			}
		}
	close(INFILE);

	#Remove o arquivo
	system "rm $output";
	if($flag eq 'BestHit')
	{
		return @BestHit;
	}
	else
	{
		return @keegArray;
	}
}

sub SetInformation
{
	$numberkeeg	= shift;
	$output	= shift;

	if(@_)
	{
		$numberkeeg{numberkeeg}	= $_[0];
		$output{output}		= $_[1];
	}

	my $m = WWW::Mechanize->new;

	eval{$m->get("http://www.genome.jp/dbget-bin/www_bget?$numberkeeg");};

	if($m->success)
	{
		#recebendo e tirando possíveis terminadores inválidos
		my $html = $m->content;
		$html =~ s/(\n\r|\r\n)|\r/\n/g;
		$html =~ s/<tbody>//g;
		$html =~ s/<\/tbody>//g;

		#Instanciando HTML::TreeBuilder::XPath;
		my $tree = HTML::TreeBuilder::XPath->new_from_content($html);

		#Agora é o pulo-do-gato!
		my @links = $tree->findnodes("/html//table//table//form//table/tr/td/table/tr");
		if(@links > 0)
		{
			map{
				if(ref($_) =~ /HTML::Element/)
				{
					# Agora estamos lidando com HTML::Element
					my $link = $_;

					open(OUT, ">>$output");
						print OUT "\n".$link->as_text();
					close(OUT);
				}
			}@links;

			# Apaga os valores deste array
			$Enzyme	= '';
			@pathways	= ();
			@Orthology	= ();
			# Abre o arquivo e começa a busca por padrões
			open(INFILE,"<$output");
				while($line =<INFILE>)
				{
					if($line =~ /^K.[0-9]/)
					{
						$line =~ s/[\W\-]//;
						$line =~ s/[\W\-]/\*/;
						@Orthology = ();
						@Orthology = split(/\*/,$line);
					}
					elsif($line =~ /EC:/)
					{
						@temp1 = ();
						@Enzyme= ();
						$Enzyme= '';
						@temp1 = split(/EC:/,$line);
						$temp1 = $temp1[1];
						$temp1 =~ s/]//g;
						$Enzyme= $temp1;
					}
					elsif($line =~ /^[a-z]{3}.[0-9]/ or $line =~ /^Pathway/)
					{
						if($line =~ /Pathway/)
						{
							$line = s/Pathway//;
						}
						$line =~ s/[\W\-]//;
						$line =~ s/[\W\-]/\*/;
						@temp2 = ();
						@temp2 = split(/\*/,$line);
						push @pathways,[@temp2];
					}
				}
			close(INFILE);

			#EXTREMAMENTE ESSENCIAL PARA EVITAR MEMORY LEAK!
			$tree = $tree->delete;
		}
	}
	system "rm $output";
}

sub GetOrthology
{
	return @Orthology;
}

sub GetEnzyme
{
	return $Enzyme;
}

sub GetPathways
{
	return @pathways;
}
return 1
