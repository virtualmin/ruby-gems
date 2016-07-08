# Functions for finding and installing Ruby gems packages
use strict;
use warnings;
our (%config);
our $module_config_directory;

BEGIN { push(@INC, ".."); };
eval "use WebminCore;";
&init_config();

my $available_gems_cache = "$module_config_directory/available";

# check_gems()
# Returns an error message if GEMS is not installed, or undef
sub check_gems
{
if (!&has_command("ruby")) {
	return &text('check_ecmd2', "<tt>ruby</tt>");
	}
if (!&has_command($config{'gem'})) {
	return &text('check_ecmd', "<tt>$config{'gem'}</tt>");
	}
return undef;
}

# list_installed_gems_modules()
# Returns a list of available Ruby GEMS modules, as hash refs
sub list_installed_gems_modules
{
my @rv;
no strict "subs"; # XXX make lexical
&open_execute_command(GEMS, "$config{'gem'} list --local -d", 1);
while(<GEMS>) {
	s/\r|\n//g;
	if (/^(\S+)\s+\((.*)\)/) {
		# Start of a new gem
		my $gem = { 'name' => $1,
			        'versions' => [ split(/\s*,\s*/, $2) ] };
		push(@rv, $gem);
		}
	elsif (/^\*/) {
		# Skip header line
		}
	elsif (/^\s+(\S.*\S):\s+(.*)$/ && @rv) {
		# Tag line
		my ($tag, $val) = (lc($1), $2);
		$tag =~ s/\s*\(([0-9\.]+)\)$//;
		if ($tag) {
			$rv[$#rv]->{$tag} ||= $val;
			}
		}
	elsif (/^\s+(\S.*)/ && @rv) {
		# Description
		$rv[$#rv]->{'desc'} .= "\n" if ($rv[$#rv]->{'desc'});
		$rv[$#rv]->{'desc'} .= $_;
		}
	}
close(GEMS);
use strict "subs";
return @rv;
}

# list_available_gems_modules()
# Returns a list of GEMS modules that can be installed. May call &error if
# the list cannot be fetched. Caches results for up to 1 hour.
sub list_available_gems_modules
{
# First check cache
my @st = stat($available_gems_cache);
if (@st && $st[9] > time()-60*60) {
	# Can use cache
	my $ser = &read_file_contents($available_gems_cache);
	my $rv = &unserialise_variable($ser);
	if (@$rv > 5) {
		return @$rv;
		}
	}

# Really download list. Try this a couple of times, as the first time
# gem list is run it just outputs a message ..
my $tries = 0;
my @rv;
while($tries++ < 2) {
	no strict "subs"; # XXX lexical?
	&open_execute_command(GEMS, "$config{'gem'} list --remote", 1);
	while(<GEMS>) {
		s/\r|\n//g;
		if (/^(\S+)\s+\((.*)\)/) {
			# Start of a new gem
			my $gem = { 'name' => $1,
				        'versions' => [ split(/\s*,\s*/, $2) ] };
			push(@rv, $gem);
			}
		elsif (/^\*/) {
			# Skip header line
			}
		elsif (/^\s+(.*)/) {
			# Description
			$rv[$#rv]->{'desc'} .= "\n" if ($rv[$#rv]->{'desc'});
			$rv[$#rv]->{'desc'} .= $_;
			}
		}
	close(GEMS);
	use strict "subs";
	last if (@rv > 1);
	}

# Write to cache and return
no strict "subs";
&open_tempfile(CACHE, ">$available_gems_cache");
&print_tempfile(CACHE, &serialise_variable(\@rv));
&close_tempfile(CACHE);
use strict "subs";
return @rv;
}

# install_gems_module(name, [version])
# Attempts to install the specified module, returning undef if OK or an
# error message on failure
sub install_gems_module
{
my ($name, $version) = @_;
my $cmd = "$config{'gem'} install ".quotemeta($name).
	     " --include-dependencies".
	     ($version ? " --version $version" : "");
&foreign_require("proc", "proc-lib.pl");
my ($fh, $fpid) = &proc::pty_process_exec($cmd);
my $out;
our $wait_for_input; # XXX This is a weird code smell.
while(1) {
	my $rv = &wait_for($fh, "Select which gem");
	$out .= $wait_for_input;
	if ($rv < 0) {
		# All done
		last;
		}
	else {
		# Start of a block asking for a version
		$rv = &wait_for($fh, ">");
		$out .= $wait_for_input;
		my @lines = split(/\r?\n/, $wait_for_input);
		my $vernum;
		foreach my $l (@lines) {
			if ($l =~ /^\s*(\d+)\.\s*(\S+)\s+([0-9\.]+)\s+\(ruby\)/) {
				$vernum = $1;
				last;
				}
			}
		if ($vernum) {
			&sysprint($fh, "$vernum\n");
			}
		else {
			return "Failed to parse version numbers : $wait_for_input";
			}
		}
	}
close($fh);
return $out =~ /error/i ? "<pre>$out</pre>" : undef;
}

# uninstall_gems_module(name, version)
# Attempts to delete the specified module, returning undef if OK or an
# error message on failure
sub uninstall_gems_module
{
my ($name, $ver) = @_;
my $out = &backquote_logged("$config{'gem'} uninstall ".
			       quotemeta($name).
			       ($ver ? " --version $ver" : " --all")." 2>&1");
return $? ? "<pre>$out</pre>" : undef;
}

# uninstall_gems_modules(&names)
# Attempts to delete the specified modules list, returning undef if OK or an
# error message on failure
sub uninstall_gems_modules
{
my ($names) = @_;
my $out = &backquote_logged("$config{'gem'} uninstall ".
			      join(" ", map { quotemeta($_) } @$names).
			      " --all 2>&1");
return $? ? "<pre>$out</pre>" : undef;
}

1;
