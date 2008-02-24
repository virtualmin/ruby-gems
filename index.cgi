#!/usr/local/bin/perl
# Show a list of installed Ruby modules, and a form to add one

require './ruby-gems-lib.pl';
&ui_print_header(undef, $text{'index_title'}, "", undef, 1, 1);
&ReadParse();

# Check for gems
$err = &check_gems();
if ($err) {
	&ui_print_endpage(
		&text('index_egems', $err, "../config.cgi?$module_name"));
	}

# Show installed
print &ui_subheading($text{'index_mods'});
@mods = &list_installed_gems_modules();
if (@mods) {
	print &ui_form_start("deletes.cgi", "post");
	@links = ( &select_all_link("d"),
		   &select_invert_link("d") );
	@tds = ( "width=5" );
	print &ui_links_row(\@links);
	print &ui_columns_start([ "", $text{'index_name'},
				  $text{'index_versions'},
				  $text{'index_desc'} ]);
	foreach $m (sort { lc($a->{'name'}) cmp lc($b->{'name'}) } @mods) {
		@dl = split(/\n/, $m->{'desc'});
		@vers = map { "<a href='view.cgi?name=".&urlize($m->{'name'}).
			      "&version=$_'>$_</a>" }
			    @{$m->{'versions'}};
		print &ui_checked_columns_row([
		  &html_escape($m->{'name'}),
		  join("&nbsp;|&nbsp;", @vers),
		  $dl[0] ], \@tds,
		  "d", $m->{'name'});
		}
	print &ui_columns_end();
	print &ui_links_row(\@links);
	print &ui_form_end([ [ "delete", $text{'index_delete'} ] ]);
	}
else {
	print "<b>$text{'index_none'}</b><p>\n";
	}

# Show install form
print &ui_subheading($text{'index_header'});

# Since there are so many, show a search form
print &ui_form_start("index.cgi");
print "<b>$text{'index_search'}</b>\n";
print &ui_textbox("search", $in{'search'}, 30),"\n";
print &ui_submit($text{'index_sok'});
print &ui_form_end();

if (defined($in{'search'})) {
	@avail = &list_available_gems_modules();
	@avail = grep { $_->{'name'} =~ /\Q$in{'search'}\E/i ||
			$_->{'desc'} =~ /\Q$in{'search'}\E/i } @avail;
	if (@avail) {
		if ($in{'search'}) {
			print &text('index_results',
			   "<tt>".&html_escape($in{'search'})."</tt>"),"<br>\n";
			}
		print &ui_form_start("install.cgi", "post");
		print &ui_columns_start([ "", $text{'index_name'},
					  $text{'index_version'},
					  $text{'index_desc'} ]);
		foreach $m (sort { lc($a->{'name'}) cmp lc($b->{'name'}) }
				 @avail) {
			@dl = split(/\n/, $m->{'desc'});
			print &ui_radio_columns_row([
				"<a href='iview.cgi?name=".
				  &urlize($m->{'name'})."'>".
				"$m->{'name'}</a>",
				$m->{'versions'}->[0],
				$dl[0] || "<br>" ], \@tds,
				"mod", $m->{'name'}."/".$m->{'versions'}->[0]);
			}
		print &ui_columns_end();
		print &ui_form_end([ [ "install", $text{'index_ok'} ] ]);
		}
	else {
		print &text('index_noresults',
			    "<tt>".&html_escape($in{'search'})."</tt>"),"<p>\n";
		}
	}

&ui_print_footer("/", $text{'index'});

