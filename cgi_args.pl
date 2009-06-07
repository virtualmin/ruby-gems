
do 'ruby-gems-lib.pl';

sub cgi_args
{
my ($cgi) = @_;
if ($cgi eq 'view.cgi') {
	my @mods = &list_installed_gems_modules();
	return @mods ? 'name='.&urlize($mods[0]->{'name'}).
		       '&version='.&urlize($mods[0]->{'versions'}->[0])
		     : 'none';
	}
return undef;
}
