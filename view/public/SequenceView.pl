#!/usr/bin/perl

# Using local modules
use lib '/var/www/gsm/model/';
use lib '/var/www/gsm/controller/';

# Usando módulos necessários o sistema
use CGI;
use Layout;
use SequenceViewController;
use Manipulation;
use GeneFindController;

# Instancing the modules Objects
my $layout 	= new Layout;
my $page   	= new CGI;

# Using methods the Objects
	print $page->header(-charset=>'utf-8');
	print $page->start_html("Resultado da Busca");
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

# Header of cadaster
	print '<center><H2><br>';
		print 'Detalhamento do Isolado <br>';
	print '</center></H2>';
	print '<br><br>';
		
# Recebe o valor passado via get
  
  	$idseq = $page->param('idseq'); 
# Show Sequence
	$result = SequenceViewController::QuerySeq($idseq);

# Imprimindo resultado
	foreach $s (@$result)
	{
		# Conta quantidade de pares de base
		$comprimento = length(@$s[14]);
		# Passando sequencia para uma variável scalar
		$sequence	 = @$s[14];
		# Passando as bases para um array
		@bases = split(//,$sequence);

		# Inicializando as varias contadoras
		$a = 0,$c = 0,$g = 0,$t = 0,$n = 0;

		# Lendo base a base
		foreach $i (0..$#bases)
		{
			# Se base A incrementa variavel a
			if($bases[$i] eq "A" or $bases[$i] eq "a"){$a++}
			# Se base C incrementa variavel c
			if($bases[$i] eq "C" or $bases[$i] eq "c"){$c++}
			# Se base G incrementa variavel g
			if($bases[$i] eq "G" or $bases[$i] eq "g"){$g++}
			# Se base T incrementa variavel t
			if($bases[$i] eq "T" or $bases[$i] eq "t"){$t++}
			# Se base N incrementa variavel n (base indefinida)
			if($bases[$i] eq "N" or $bases[$i] eq "n"){$n++}
		}
		# Monta na telas as informações dos isolados
		print 'Codigo do Isolado:' .' '. @$s[1]  . '<br>' ;
		print '<br>';
		print 'Especie		:' .' '. @$s[3]  . '<br>' ;
		print '<br>';
		print 'Hospedeiro		:' .' '. @$s[4]  . '<br>' ;
		print '<br>';
		print 'Cidade		:' .' '. @$s[8]  .'-'. @$s[7]	.'<br>' ;
		print '<br>';
		print 'Latitude		:' .' '. @$s[9]  . '<br>';
		print 'Longitude		:' .' '. @$s[10] . '<br>';
		print '<br>';
		print 'Tipo			:' .' '. @$s[12] . '<br>' ;
		print '<br>';
		print 'Data da coleta	:' .' '. @$s[5]  . '<br>' ;
		print '<br>';
		print 'Informacoes	:' . '<br>';
		print  @$s[6]  . '<br>' ;
		print '<br>';
		print 'Indentificador	:' .' '. @$s[13] . '<br>' ;
		print '<br>';
		print 'Comprimento	:' .' '. $comprimento  . '<br>' ;
		print '<br>';
		print "A: $a".'  '."T: $t".'  '."C: $c".'  '."G: $g".'  '."N: $n".'<br>';
		print '<br>';
		print "<a href='?idseq=$idseq' 			style=text-decoration:none>	Molde		</a> \t\t";
		print "<a href='?idseq=$idseq&rev=Reversa'	style=text-decoration:none>	Reversa 	</a> \t\t";
		print "<a href='?idseq=$idseq&prot=Proteina'	style=text-decoration:none>	AA-Molde	</a> \t\t";
		print "<a href='?idseq=$idseq&protrev=Proteina'	style=text-decoration:none>	AA-Reversa	</a> \t\t";
		print "<a href='?idseq=$idseq&fasta=Fasta'	style=text-decoration:none>	FASTA		</a> \t\t";
		print "<a href='Anotacao.pl?idseq=$idseq&anotac=anotacao'	style=text-decoration:none>	Anotações	</a> <br>";
		print '<br>';
		
		if($page->param('anotac') eq '')
		{
			print "<div class='sequence'>";
		
		# Verifica se o contexto de impressão, por exemplo : reverso complementar, proteina ou sequencia
		
		# Imprimindo fita reversa
		if($page->param('rev') ne '' )
		{
			# Imprima a reversa complementar
			$seq = @$s[14];
			$seq = Manipulation::Revcom($seq);
			$seq =~ tr/ACGT/TGCA/;
			$seq =~ tr/actg/tgca/;
			@sequence = $seq;
		}
		# Testa para ver se é sequência de aminoácidos
		elsif($page->param('prot') ne '' )
		{
			#Imprime os  aminoácidos
			$seq = @$s[14];
			$seq = Manipulation::Translate($seq);
			@sequence = $seq;
		}
		elsif($page->param('protrev') ne '' )
		{
			#Imprime os  aminoácidos
			$seq = reverse @$s[14];
			$seq = Manipulation::Translate($seq);
			@sequence = $seq;
		}
		else
		# Passa o valor da fita molde
		{
			# Pega a fita molde
			@sequence = @$s[14];
		}
		# Para inserir intervalo de 10 em 10 bases
		foreach $i(0..$#sequence)
		{
			if($page->param('prot') ne '')
			{
				@partes = split(/([ACDEFGHIKLMNPQRSTVWY*]{100})/,$sequence[$i]);
			}
			elsif($page->param('protrev') ne '')
			{
				@partes = split(/([ACDEFGHIKLMNPQRSTVWY*]{100})/,$sequence[$i]);
			}
			elsif($page->param('fasta') ne '')
			{
				#para separar a linha a cada 10 bases
				print "@$s[13]<br>";
				@partes = split(/([ACGTNXacgtn]{100})/,$sequence[$i]);
			}
			else
			{
				#para separar a linha a cada 10 bases
				@partes = split(/([ACGTNXacgtn]{100})/,$sequence[$i]);
			}
			# Para imprimir cada bloco de 10 bases
			foreach $j (0..$#partes)
			{
				# Verifica se vazio e imprime o fragmentos
				if($partes[$j] ne "" && $page->param('anotac') eq '' )
				{
					print "$partes[$j]"."<br>";
				}
			}
		}
		print '</div>';
		}

		if( $page->param('anotac') ne '')
		{
			$programas = GeneFindController::Programas($idseq);
			foreach $i (@$programas)
			{
				print "<a href='?idseq=$idseq&anotac=anotacao&program=@$i[0]' style=text-decoration:none> @$i[0] </a> \t\t";
			}
			
			if($page->param('program') ne '')
			{	
				# Busca os dados de anotações
				$dados = GeneFindController::QueryData($idseq,$page->param('program'));
				print "<br>";
				#print "<table>";
				print "<tr align=center><td>Região</td><td>Fita</td><td>Inicio</td><td>Termino</td><td>Gene</td> </tr><br>";
				foreach $i (@$dados)
				{
					print "<tr align=center><td>@$i[0]</td> <td>@$i[1]</td><td>@$i[2]</td><td>@$i[3]</td><td>@$i[4]</td> <br></tr>";
				}
				#print "</table>";
			}
		}
	}

# Encerra o formulário
	$page->end_form();
	print '<br>';

# Exibe o rodapé
	print $layout->lower();

# Finaliza a página
	print $page->end_html();
