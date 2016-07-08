#!/usr/local/bin/perl
# Delete one gem
use strict;
use warnings;
our (%text, %in); 

require './ruby-gems-lib.pl';
&ReadParse();

if ($in{'upgrade'}) {
	# Special case - redirect to install URL
	&redirect("install.cgi?mod=".&urlize($in{'name'}).
		  "&version=".&urlize($in{'version'}));
	exit;
	}

&error_setup($text{'delete_err'});
&ui_print_header(undef, $text{'delete_title'}, "");

if ($in{'confirm'}) {
	# Do the delete
	print &text('delete_doing', "<tt>$in{'name'}</tt>",
                                     $in{'dversion'}),"<p>\n";
	my $err = &uninstall_gems_module($in{'name'}, $in{'dversion'});
	if ($err) {
		print $err,"\n";
		print $text{'delete_failed'},"<br>\n";
		}
	else {
		print $text{'delete_done'},"<br>\n";
		}
	&webmin_log("delete", undef, $in{'name'},
		    { 'version' => $in{'dversion'} });
	}
else {
	# Ask first
	print &ui_form_start("delete.cgi", "post");
	print &ui_hidden("name", $in{'name'}),"\n";
	print &ui_hidden("dversion", $in{'dversion'}),"\n";
	print "<center>\n";
	print &text('delete_rusure', "<tt>$in{'name'}</tt>",
				     $in{'dversion'}),"<p>\n";
	print &ui_submit($text{'delete_ok'}, "confirm"),"<p>\n";
	print "</center>\n";
	print &ui_form_end();
	}

&ui_print_footer("", $text{'index_return'});
