#!/usr/local/bin/perl
# Show full details of an installed Gems module

require './ruby-gems-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'view_title'}, "");

($mod) = grep { $_->{'name'} eq $in{'name'} } &list_installed_gems_modules();
@tds = ( "nowrap" );
print &ui_form_start("delete.cgi");
print &ui_hidden("name", $in{'name'}),"\n";
print &ui_hidden("dversion", $in{'version'}),"\n";
print &ui_table_start($text{'view_header'}, "width=50%", 2);

print &ui_table_row($text{'view_name'}, "<tt>$mod->{'name'}</tt>", 1, \@tds);

print &ui_table_row($text{'view_version'}, $in{'version'}, 1, \@tds);

print &ui_table_row($text{'view_desc'},
		    &html_escape($mod->{'desc'}), 1, \@tds);

if ($mod->{'author'}) {
	print &ui_table_row($text{'view_author'},
		&html_escape($mod->{'author'}), 1, \@tds);
	}

if ($mod->{'homepage'}) {
	print &ui_table_row($text{'view_homepage'},
		"<a href='$mod->{'homepage'}'>$mod->{'homepage'}</a>", 1,\@tds);
	}

($avail) = grep { $_->{'name'} eq $in{'name'} } &list_available_gems_modules();
if ($avail) {
	print &ui_table_row($text{'view_avail'},
			    &ui_select("version", $mod->{'version'},
			       [ map { [ $_ ] } @{$avail->{'versions'}} ])."\n".
			    &ui_submit($text{'view_upgrade'}, "upgrade"),
			    1, \@tds);
	}

print &ui_table_end();
print &ui_form_end([ [ "delete", $text{'view_delete'} ] ]);

&ui_print_footer("", $text{'index_return'});

