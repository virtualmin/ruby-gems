use Test::Strict tests => 3;                      # last test to print

syntax_ok( 'iview.cgi' );
strict_ok( 'iview.cgi' );
warnings_ok( 'iview.cgi' );
