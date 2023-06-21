package Pdbe;

# Módulo utilizado para fazer a consulta on-line
use WWW::Mechanize;
use HTML::TreeBuilder::XPath;

sub SearchPdbe
{
	my $sequence = shift;
	my $option   = shift;

	if(@_)
	{
		$sequence{sequence} = $_[0];
		$option{option}     = $_[1];
	}

	$m = WWW::Mechanize->new;

	$m->get("http://www.ebi.ac.uk/pdbe-srv/view/search?search_type=advanced&sequence=$sequence&evalue=1e-2");

	# Recebe os dados e elimina algumas incoerẽncias nos dados
	$html = $m->content;
	$html =~ s/(\n\r|\r\n)|\r/\n/g;
	$html =~ s/<tbody>//g;
	$html =~ s/<\/tbody>//g;


	# Instanciando HTML::TreeBuilder::XPath;
	$tree = HTML::TreeBuilder::XPath->new_from_content($html);

	# Pega os dados no formulário da página
	@links = $tree->findnodes("/html/body//table/tr");

	# Limpa o array de dados para evitar acumulo de dados e gerar lixo em memória
	@arraydados	= ();
	@best		= ();

	if(@links>0)
	{
		map
		{
			if(ref($_) =~ /HTML::Element/)
			{
				# Agora estamos lidando com HTML::Element
				my $link = $_;
				if($link->as_text() =~ /^[0-9].[a-z]/)
				{
					# Limpa o array de dados para evitar acumulo de dados e gerar lixo em memória
					@temp  =();
					@temp1 =();
					@evalue=();
					@dados =();
					@temporario = ();

					# Pega os valores das linhas formata e coloca em um array
					$register = $link->as_text();
					# Retira caracteres para não gerar erros
					$register =~ s/\[//g;
					$register =~ s/\]//g;
					$register =~ s/\{//g;
					$register =~ s/\}//g;
					$register =~ s/\(//g;
					$register =~ s/\)//g;

					$accessNumber = substr($register,0,4);
					$temporario   = substr($register,4);

					@temp = split(/[0-9]\.[0-9]*.[e-].[0-9]*/,$temporario);

					$descricao = $temp[0];
					
					@temporario = split(/[[:blank:]]/,$temporario);
					if(grep (/[0-9]\.[0-9]*.[e-].[0-9]*/,@temporario))
					{
						@evalue = grep (/[0-9]\.[0-9]*.[e-].[0-9]*/,@temporario);
					}
					elsif(grep (/[0-9]\.[0-9]*/,@temporario))
					{
						@evalue = grep (/[0-9]\.[0-9]*/,@temporario);
						$evalue[0] =~ s/[a-z]//g;
						$evalue[0] =~ s/\[//g;
						$evalue[0] =~ s/\]//g;
					}

					@dados  	= ($accessNumber,$descricao,$evalue[0]);
					$evalue[0]	= 0;
					if($option eq 'best' or $option eq 'BEST')
					{
						@best = [@dados];
						return @best;
					}
					push @arraydados,[@dados];
				}
			}
		}@links;
	}
	$tree->delete;

	return @arraydados;

}
return 1
