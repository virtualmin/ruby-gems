#!/usr/local/bin/perl
# Install one gems module
use strict;
use warnings;
our (%text, %in);

require './ruby-gems-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'install_title'}, "");

if ($in{'mod'} =~ /^(\S+)\/(\S+)$/) {
	# Called from index with name and version in one parameter
	$in{'mod'} = $1;
	$in{'version'} = $2;
	}

if ($in{'version'}) {
	print &text('install_doing2', "<tt>$in{'mod'}</tt>",
				      $in{'version'}),"<br>\n";
	}
else {
	print &text('install_doing', "<tt>$in{'mod'}</tt>"),"<br>\n";
	}
my $err = &install_gems_module($in{'mod'}, $in{'version'});
if ($err) {
	print $err,"\n";
	print $text{'install_failed'},"<br>\n";
	}
else {
	print $text{'install_done'},"<br>\n";
	&webmin_log("install", undef, $in{'mod'});
	}

&ui_print_footer("", $text{'index_return'});
