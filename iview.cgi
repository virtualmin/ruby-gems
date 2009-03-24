#!/usr/local/bin/perl
# Show full details of an available Gems module

require './ruby-gems-lib.pl';
&ReadParse();
&ui_print_header(undef, $text{'view_title'}, "");

($mod) = grep { $_->{'name'} eq $in{'name'} } &list_available_gems_modules();
@tds = ( "nowrap" );
print &ui_form_start("install.cgi");
print &ui_hidden("mod", $mod->{'name'}),"\n";
print &ui_table_start($text{'view_header'}, "width=50%", 2);

print &ui_table_row($text{'view_name'}, "<tt>$mod->{'name'}</tt>", 1, \@tds);

print &ui_table_row($text{'view_versions'},
		    &ui_select("version", undef,
			       [ map { [ $_ ] } @{$mod->{'versions'}} ]),
		    1, \@tds);

if ($mod->{'desc'}) {
	print &ui_table_row($text{'view_desc'},
			    &html_escape($mod->{'desc'}), 1, \@tds);
	}

print &ui_table_end();
print &ui_form_end([ [ "install", $text{'view_install'} ] ]);

&ui_print_footer("", $text{'index_return'});

