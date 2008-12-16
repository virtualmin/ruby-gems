# Functions for finding and installing Ruby gems packages

do '../web-lib.pl';
&init_config();
do '../ui-lib.pl';

$available_gems_cache = "$module_config_directory/available";

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
local @rv;
&open_execute_command(GEMS, "$config{'gem'} list --local -d", 1);
while(<GEMS>) {
	s/\r|\n//g;
	if (/^(\S+)\s+\((.*)\)/) {
		# Start of a new gem
		local $gem = { 'name' => $1,
			       'versions' => [ split(/\s*,\s*/, $2) ] };
		push(@rv, $gem);
		}
	elsif (/^\*/) {
		# Skip header line
		}
	elsif (/^\s+(\S.*\S):\s+(.*)$/ && @rv) {
		# Tag line
		local ($tag, $val) = (lc($1), $2);
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
return @rv;
}

# list_available_gems_modules()
# Returns a list of GEMS modules that can be installed. May call &error if
# the list cannot be fetched. Caches results for up to 1 hour.
sub list_available_gems_modules
{
# First check cache
local @st = stat($available_gems_cache);
if (@st && $st[9] > time()-60*60) {
	# Can use cache
	local $ser = &read_file_contents($available_gems_cache);
	local $rv = &unserialise_variable($ser);
	if (@$rv > 5) {
		return @$rv;
		}
	}

# Really download list. Try this a couple of times, as the first time
# gem list is run it just outputs a message ..
local $tries = 0;
local @rv;
while($tries++ < 2) {
	&open_execute_command(GEMS, "$config{'gem'} list --remote", 1);
	while(<GEMS>) {
		s/\r|\n//g;
		if (/^(\S+)\s+\((.*)\)/) {
			# Start of a new gem
			local $gem = { 'name' => $1,
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
	last if (@rv > 1);
	}

# Write to cache and return
&open_tempfile(CACHE, ">$available_gems_cache");
&print_tempfile(CACHE, &serialise_variable(\@rv));
&close_tempfile(CACHE);
return @rv;
}

# install_gems_module(name, [version])
# Attempts to install the specified module, returning undef if OK or an
# error message on failure
sub install_gems_module
{
local ($name, $version) = @_;
local $cmd = "$config{'gem'} install ".quotemeta($name).
	     " --include-dependencies".
	     ($version ? " --version $version" : "");
&foreign_require("proc", "proc-lib.pl");
local ($fh, $fpid) = &proc::pty_process_exec($cmd);
local $out;
while(1) {
	local $rv = &wait_for($fh, "Select which gem");
	$out .= $wait_for_input;
	if ($rv < 0) {
		# All done
		last;
		}
	else {
		# Start of a block asking for a version
		$rv = &wait_for($fh, ">");
		$out .= $wait_for_input;
		local @lines = split(/\r?\n/, $wait_for_input);
		local $vernum;
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
local ($name, $ver) = @_;
local $out = &backquote_logged("$config{'gem'} uninstall ".
			       quotemeta($name).
			       ($ver ? " --version $ver" : " --all")." 2>&1");
return $? ? "<pre>$out</pre>" : undef;
}

# uninstall_gems_modules(&names)
# Attempts to delete the specified modules list, returning undef if OK or an
# error message on failure
sub uninstall_gems_modules
{
local ($names) = @_;
local $out = &backquote_logged("$config{'gem'} uninstall ".
			      join(" ", map { quotemeta($_) } @$names).
			      " --all 2>&1");
return $? ? "<pre>$out</pre>" : undef;
}



1;

