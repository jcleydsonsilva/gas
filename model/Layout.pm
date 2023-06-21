package ::Layout;

$template = '/var/www/gsm/view/template/';

sub new
{
	my $class = shift();
	my $self = {};
	bless($self, $class);
	return $self;
}

sub menu
{
	my $level = shift;
	if(@_)
	{
		$level = $_[0];
	}

	if($level == 0)
	{
		my $menu = `cat $template/menu-adm.smg`; 
		return $menu;
	}
	elsif($level == 1)
	{
		my $menu = `cat $template/menu-anotator.smg`;
		return $menu;
	}
	elsif($level == 2)
	{
		my $menu = `cat $template/menu-user.smg`;
		return $menu;
	}

}

sub header
{
	my($self) = shift;

	my $header = `cat $template/header.smg`; 
	return $header;
}

sub bodyTitle
{
 
	my($self) = shift;

		$bodyTitle = '
			<br>
			<br>
			<h2 class="titulo1">Genome System Mining</h2>';

		return $bodyTitle;	
}

sub lower
{
	my($self) = shift;
	
	my $lower = `cat $template/lower.smg`; 
	return $lower;
	
}
return 1;

