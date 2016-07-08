#!/usr/local/bin/perl
# Delete a bunch of Gems modules, after asking for confirmation
use strict;
use warnings;
our (%text, %in);

require './ruby-gems-lib.pl';
&ReadParse();

&error_setup($text{'deletes_err'});
my @d = split(/\0/, $in{'d'});
@d || &error($text{'deletes_enone'});
&ui_print_header(undef, $text{'deletes_title'}, "");

if ($in{'confirm'}) {
	# Do the delete
	print &text('deletes_doing',
	    join(" ", map { "<tt>$_</tt>" } @d)),"<br>\n";
	my $err = &uninstall_gems_modules(\@d);
	if ($err) {
		print $err,"\n";
		print $text{'deletes_failed'},"<br>\n";
		}
	else {
		print $text{'deletes_done'},"<br>\n";
		}
	&webmin_log("deletes", undef, join(" ", @d));
	}
else {
	# Ask first
	print &ui_form_start("deletes.cgi", "post");
	foreach my $d (@d) {
		print &ui_hidden("d", $d),"\n";
		}
	print "<center>\n";
	print &text('deletes_rusure', scalar(@d)),"<p>\n";
	print &ui_submit($text{'deletes_ok'}, "confirm"),"<p>\n";
	print &text('deletes_mods',
		join(" ", map { "<tt>$_</tt>" } @d)),"\n";
	print "</center>\n";
	print &ui_form_end();
	}

&ui_print_footer("", $text{'index_return'});
